package com.example.tudy.ai;

import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
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
     * AI 분류 결과와 목표 카테고리가 일치하는지 확인
     * @param classificationResult AI 분류 결과
     * @param goalCategoryName 목표의 카테고리명
     * @return 매칭 결과
     */
    public CategoryMatchResult matchCategory(ImageClassificationService.ClassificationResult classificationResult, 
                                            String goalCategoryName) {
        
        String aiLabel = classificationResult.getLabel();
        String mappedCategory = LABEL_TO_CATEGORY.get(aiLabel);
        
        if (mappedCategory == null) {
            log.warn("알 수 없는 AI 라벨: {}", aiLabel);
            return new CategoryMatchResult(false, aiLabel, goalCategoryName, classificationResult.getConfidence(),
                    "인식된 카테고리를 매핑할 수 없습니다.");
        }
        
        boolean isMatch = mappedCategory.equals(goalCategoryName);
        String message = isMatch ? 
                String.format("사진이 '%s' 카테고리로 올바르게 인식되었습니다.", mappedCategory) :
                String.format("사진이 '%s'로 인식되었지만, 목표 카테고리는 '%s'입니다.", mappedCategory, goalCategoryName);
        
        log.info("카테고리 매칭 결과 - AI: {}, 목표: {}, 일치: {}, 신뢰도: {}", 
                mappedCategory, goalCategoryName, isMatch, classificationResult.getConfidence());
        
        return new CategoryMatchResult(isMatch, mappedCategory, goalCategoryName, 
                classificationResult.getConfidence(), message);
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
