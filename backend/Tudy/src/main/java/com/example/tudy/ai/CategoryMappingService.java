package com.example.tudy.ai;

import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class CategoryMappingService {

    // AI 모델 라벨을 카테고리명으로 매핑
    private static final Map<String, String> LABEL_TO_CATEGORY = new HashMap<>();

    static {
        LABEL_TO_CATEGORY.put("카페", "카페");
        LABEL_TO_CATEGORY.put("운동", "운동");
        LABEL_TO_CATEGORY.put("공부", "공부");
    }

    /**
     * CLIP 분류 결과와 목표 카테고리가 일치하는지 확인
     * @param clipResult CLIP 분류 결과
     * @param goalCategoryName 목표의 카테고리명
     * @return 매칭 결과
     */
    public CategoryMatchResult matchCategory(ClipImageClassificationService.ClipClassificationResult clipResult,
                                             String goalCategoryName) {

        String recognizedCategory = clipResult.getBestMatch();

        // CLIP은 직접 카테고리를 반환하므로 매핑이 필요없음
        boolean isMatch = recognizedCategory.equals(goalCategoryName);
        String message = isMatch ?
                String.format("사진이 '%s' 카테고리로 올바르게 인식되었습니다.", recognizedCategory) :
                String.format("사진이 '%s'로 인식되었지만, 목표 카테고리는 '%s'입니다.", recognizedCategory, goalCategoryName);

        log.info("CLIP 카테고리 매칭 결과 - 인식: {}, 목표: {}, 일치: {}, 신뢰도: {}",
                recognizedCategory, goalCategoryName, isMatch, clipResult.getConfidence());

        return new CategoryMatchResult(isMatch, recognizedCategory, goalCategoryName,
                clipResult.getConfidence(), message);
    }

    /**
     * 텍스트 쿼리 기반 매칭 (더 유연한 방식)
     * @param clipResult CLIP 분류 결과
     * @param goalCategoryName 목표의 카테고리명
     * @param textQueries 사용된 텍스트 쿼리 목록
     * @return 매칭 결과
     */
    public CategoryMatchResult matchCategoryWithTextQueries(ClipImageClassificationService.ClipClassificationResult clipResult,
                                                            String goalCategoryName, List<String> textQueries) {

        String bestQuery = clipResult.getBestMatch();

        // 텍스트 쿼리에서 카테고리 추출 (간단한 키워드 매칭)
        String recognizedCategory = extractCategoryFromQuery(bestQuery, goalCategoryName);

        boolean isMatch = recognizedCategory.equals(goalCategoryName);
        String message = isMatch ?
                String.format("사진이 '%s' 활동으로 올바르게 인식되었습니다.", recognizedCategory) :
                String.format("사진이 '%s' 활동으로 인식되었지만, 목표는 '%s'입니다.", recognizedCategory, goalCategoryName);

        log.info("CLIP 텍스트 쿼리 매칭 결과 - 쿼리: {}, 인식: {}, 목표: {}, 일치: {}, 신뢰도: {}",
                bestQuery, recognizedCategory, goalCategoryName, isMatch, clipResult.getConfidence());

        return new CategoryMatchResult(isMatch, recognizedCategory, goalCategoryName,
                clipResult.getConfidence(), message);
    }

    /**
     * 텍스트 쿼리에서 카테고리 추출
     */
    private String extractCategoryFromQuery(String query, String goalCategory) {
        // 간단한 키워드 기반 매칭
        if (query.contains("공부") || query.contains("학습") || query.contains("읽기")) {
            return "공부";
        } else if (query.contains("운동") || query.contains("헬스") || query.contains("스포츠")) {
            return "운동";
        } else if (query.contains("카페") || query.contains("커피") || query.contains("음료")) {
            return "카페";
        }

        // 기본적으로 목표 카테고리 반환 (보수적 접근)
        return goalCategory;
    }

    /**
     * 신뢰도 기반 인증 가능 여부 확인
     * @param confidence 모델의 신뢰도
     * @return 인증 가능 여부
     */
    public boolean isConfidentEnough(float confidence) {
        // 신뢰도 임계값 (70% 이상)
        float threshold = 0.7f;
        return confidence >= threshold;
    }

    /**
     * 카테고리 매칭 결과 클래스
     */
    public static class CategoryMatchResult {
        private final boolean matches;
        private final String recognizedCategory;
        private final String goalCategory;
        private final float confidence;
        private final String message;

        public CategoryMatchResult(boolean matches, String recognizedCategory, String goalCategory,
                                   float confidence, String message) {
            this.matches = matches;
            this.recognizedCategory = recognizedCategory;
            this.goalCategory = goalCategory;
            this.confidence = confidence;
            this.message = message;
        }

        public boolean isMatches() { return matches; }
        public String getRecognizedCategory() { return recognizedCategory; }
        public String getGoalCategory() { return goalCategory; }
        public float getConfidence() { return confidence; }
        public String getMessage() { return message; }

        @Override
        public String toString() {
            return String.format("CategoryMatchResult{matches=%s, recognized='%s', goal='%s', confidence=%.3f, message='%s'}",
                    matches, recognizedCategory, goalCategory, confidence, message);
        }
    }
}