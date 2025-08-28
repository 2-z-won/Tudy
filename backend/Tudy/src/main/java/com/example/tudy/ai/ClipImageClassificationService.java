
package com.example.tudy.ai;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.util.List;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class ClipImageClassificationService {

    private final WebClient.Builder webClientBuilder;

    @Value("${clip.service.url:http://localhost:5000}")
    private String clipServiceUrl;

    /**
     * CLIP 모델을 사용하여 이미지 분류 수행
     * @param imageBytes 이미지 바이트 배열
     * @param categories 분류할 카테고리 목록 (예: ["공부", "운동", "카페"])
     * @return 분류 결과
     */
    public ClipClassificationResult classifyImage(byte[] imageBytes, List<String> categories) {
        try {
            // CLIP 서비스 상태 확인
            if (!isClipServiceHealthy()) {
                log.warn("CLIP 서비스가 실행되지 않고 있습니다. 기본 분류 로직을 사용합니다.");
                return fallbackClassification(categories);
            }

            WebClient webClient = webClientBuilder.baseUrl(clipServiceUrl).build();

            // 멀티파트 폼 데이터 구성
            MultiValueMap<String, Object> parts = new LinkedMultiValueMap<>();
            parts.add("image", new ByteArrayResource(imageBytes) {
                @Override
                public String getFilename() {
                    return "image.jpg";
                }
            });
            parts.add("categories", String.join(",", categories));

            // CLIP 서비스 호출
            Map<String, Object> response = webClient.post()
                    .uri("/classify")
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .body(BodyInserters.fromMultipartData(parts))
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();

            if (response == null) {
                throw new RuntimeException("CLIP 서비스로부터 응답을 받지 못했습니다.");
            }

            String bestCategory = (String) response.get("best_category");
            Double confidence = ((Number) response.get("confidence")).doubleValue();
            @SuppressWarnings("unchecked")
            Map<String, Double> scores = (Map<String, Double>) response.get("scores");

            log.info("CLIP 분류 결과 - 카테고리: {}, 신뢰도: {}", bestCategory, confidence);

            return new ClipClassificationResult(bestCategory, confidence.floatValue(), scores);

        } catch (Exception e) {
            log.warn("CLIP 서비스 연결 실패, 기본 분류 로직 사용: {}", e.getMessage());
            return fallbackClassification(categories);
        }
    }
    
    /**
     * CLIP 서비스가 정상적으로 실행되고 있는지 확인
     */
    private boolean isClipServiceHealthy() {
        try {
            WebClient webClient = webClientBuilder.baseUrl(clipServiceUrl).build();
            Map<String, Object> response = webClient.get()
                    .uri("/health")
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();
            
            if (response != null) {
                Boolean modelLoaded = (Boolean) response.get("model_loaded");
                return Boolean.TRUE.equals(modelLoaded);
            }
            return false;
        } catch (Exception e) {
            log.debug("CLIP 서비스 상태 확인 실패: {}", e.getMessage());
            return false;
        }
    }
    
    /**
     * CLIP 서비스 연결 실패 시 사용할 기본 분류 로직
     */
    private ClipClassificationResult fallbackClassification(List<String> categories) {
        // 기본적으로 첫 번째 카테고리를 선택하고 중간 신뢰도 반환
        String defaultCategory = categories.isEmpty() ? "공부" : categories.get(0);
        float defaultConfidence = 0.7f;
        
        // 기본 점수 맵 생성
        Map<String, Double> defaultScores = new java.util.HashMap<>();
        for (String category : categories) {
            defaultScores.put(category, category.equals(defaultCategory) ? 0.7 : 0.3);
        }
        
        log.info("기본 분류 결과 - 카테고리: {}, 신뢰도: {}", defaultCategory, defaultConfidence);
        return new ClipClassificationResult(defaultCategory, defaultConfidence, defaultScores);
    }

    /**
     * 텍스트 기반 이미지 분류 (더 유연한 방식)
     * @param imageBytes 이미지 바이트 배열
     * @param textQueries 텍스트 쿼리 목록 (예: ["사람이 공부하고 있는 사진", "운동하는 사진"])
     * @return 분류 결과
     */
    public ClipClassificationResult classifyImageWithText(byte[] imageBytes, List<String> textQueries) {
        try {
            WebClient webClient = webClientBuilder.baseUrl(clipServiceUrl).build();

            MultiValueMap<String, Object> parts = new LinkedMultiValueMap<>();
            parts.add("image", new ByteArrayResource(imageBytes) {
                @Override
                public String getFilename() {
                    return "image.jpg";
                }
            });
            parts.add("text_queries", String.join("||", textQueries));

            Map<String, Object> response = webClient.post()
                    .uri("/classify-text")
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .body(BodyInserters.fromMultipartData(parts))
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();

            if (response == null) {
                throw new RuntimeException("CLIP 서비스로부터 응답을 받지 못했습니다.");
            }

            String bestQuery = (String) response.get("best_query");
            Double confidence = ((Number) response.get("confidence")).doubleValue();
            @SuppressWarnings("unchecked")
            Map<String, Double> scores = (Map<String, Double>) response.get("scores");

            log.info("CLIP 텍스트 기반 분류 결과 - 쿼리: {}, 신뢰도: {}", bestQuery, confidence);

            return new ClipClassificationResult(bestQuery, confidence.floatValue(), scores);

        } catch (Exception e) {
            log.error("CLIP 텍스트 기반 이미지 분류 중 오류 발생: ", e);
            throw new RuntimeException("이미지 분류 실패", e);
        }
    }

    /**
     * CLIP 분류 결과 클래스
     */
    public static class ClipClassificationResult {
        private final String bestMatch;
        private final float confidence;
        private final Map<String, Double> allScores;

        public ClipClassificationResult(String bestMatch, float confidence, Map<String, Double> allScores) {
            this.bestMatch = bestMatch;
            this.confidence = confidence;
            this.allScores = allScores;
        }

        public String getBestMatch() { return bestMatch; }
        public float getConfidence() { return confidence; }
        public Map<String, Double> getAllScores() { return allScores; }

        @Override
        public String toString() {
            return String.format("ClipClassificationResult{bestMatch='%s', confidence=%.3f, scores=%s}",
                    bestMatch, confidence, allScores);
        }
    }
}
