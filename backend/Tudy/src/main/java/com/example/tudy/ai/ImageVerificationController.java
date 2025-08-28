
package com.example.tudy.ai;

import com.example.tudy.user.User;
import com.example.tudy.user.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ai/image-verification")
@RequiredArgsConstructor
@Slf4j
public class ImageVerificationController {

    private final ClipImageClassificationService clipService;
    private final CategoryMappingService categoryMappingService;
    private final UserService userService;

    // 기본 카테고리 목록
    private static final List<String> DEFAULT_CATEGORIES = Arrays.asList("공부", "운동", "카페");

    // 텍스트 쿼리 목록 (더 정확한 인식을 위해)
    private static final List<String> TEXT_QUERIES = Arrays.asList(
            "사람이 책을 읽거나 공부하고 있는 사진",
            "사람이 운동하거나 헬스를 하고 있는 사진",
            "카페나 커피숍에서 음료를 마시고 있는 사진"
    );

    /**
     * 기본 카테고리 기반 이미지 인증
     */
    @PostMapping("/category/{goalCategory}")
    public ResponseEntity<ImageVerificationResponse> verifyImageByCategory(
            @PathVariable String goalCategory,
            @RequestParam("image") MultipartFile image,
            Authentication authentication) {

        if (authentication == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증이 필요합니다.");
        }

        try {
            User user = userService.getUserByEmail(authentication.getName());
            byte[] imageBytes = image.getBytes();

            // CLIP으로 이미지 분류
            ClipImageClassificationService.ClipClassificationResult clipResult =
                    clipService.classifyImage(imageBytes, DEFAULT_CATEGORIES);

            // 카테고리 매칭
            CategoryMappingService.CategoryMatchResult matchResult =
                    categoryMappingService.matchCategory(clipResult, goalCategory);

            // 신뢰도 확인
            boolean confidentEnough = categoryMappingService.isConfidentEnough(clipResult.getConfidence());
            boolean verified = matchResult.isMatches() && confidentEnough;

            String resultMessage = verified ?
                    "이미지 인증에 성공했습니다!" :
                    matchResult.getMessage() + (confidentEnough ? "" : " (신뢰도가 낮습니다.)");

            ImageVerificationResponse response = new ImageVerificationResponse(
                    verified,
                    matchResult.getRecognizedCategory(),
                    goalCategory,
                    clipResult.getConfidence(),
                    resultMessage,
                    clipResult.getAllScores()
            );

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("이미지 인증 중 오류 발생: ", e);
            return ResponseEntity.status(500)
                    .body(new ImageVerificationResponse(false, null, goalCategory, 0.0f,
                            "이미지 인증 중 오류가 발생했습니다.", null));
        }
    }

    /**
     * 텍스트 쿼리 기반 이미지 인증 (더 정확한 방식)
     */
    @PostMapping("/text-query/{goalCategory}")
    public ResponseEntity<ImageVerificationResponse> verifyImageByTextQuery(
            @PathVariable String goalCategory,
            @RequestParam("image") MultipartFile image,
            @RequestParam(value = "queries", required = false) List<String> customQueries,
            Authentication authentication) {

        if (authentication == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증이 필요합니다.");
        }

        try {
            User user = userService.getUserByEmail(authentication.getName());
            byte[] imageBytes = image.getBytes();

            // 사용할 쿼리 결정 (커스텀 쿼리가 있으면 사용, 없으면 기본 쿼리)
            List<String> queriesToUse = (customQueries != null && !customQueries.isEmpty()) ?
                    customQueries : TEXT_QUERIES;

            // CLIP으로 텍스트 기반 이미지 분류
            ClipImageClassificationService.ClipClassificationResult clipResult =
                    clipService.classifyImageWithText(imageBytes, queriesToUse);

            // 카테고리 매칭
            CategoryMappingService.CategoryMatchResult matchResult =
                    categoryMappingService.matchCategoryWithTextQueries(clipResult, goalCategory, queriesToUse);

            // 신뢰도 확인
            boolean confidentEnough = categoryMappingService.isConfidentEnough(clipResult.getConfidence());
            boolean verified = matchResult.isMatches() && confidentEnough;

            String resultMessage = verified ?
                    "이미지 인증에 성공했습니다!" :
                    matchResult.getMessage() + (confidentEnough ? "" : " (신뢰도가 낮습니다.)");

            ImageVerificationResponse response = new ImageVerificationResponse(
                    verified,
                    matchResult.getRecognizedCategory(),
                    goalCategory,
                    clipResult.getConfidence(),
                    resultMessage,
                    clipResult.getAllScores()
            );

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("텍스트 쿼리 기반 이미지 인증 중 오류 발생: ", e);
            return ResponseEntity.status(500)
                    .body(new ImageVerificationResponse(false, null, goalCategory, 0.0f,
                            "이미지 인증 중 오류가 발생했습니다.", null));
        }
    }

    /**
     * 사용 가능한 카테고리 목록 조회
     */
    @GetMapping("/categories")
    public ResponseEntity<List<String>> getAvailableCategories() {
        return ResponseEntity.ok(DEFAULT_CATEGORIES);
    }

    /**
     * 이미지 인증 응답 DTO
     */
    public static class ImageVerificationResponse {
        private boolean verified;
        private String recognizedCategory;
        private String goalCategory;
        private float confidence;
        private String message;
        private Map<String, Double> allScores;

        public ImageVerificationResponse(boolean verified, String recognizedCategory, String goalCategory,
                                         float confidence, String message, Map<String, Double> allScores) {
            this.verified = verified;
            this.recognizedCategory = recognizedCategory;
            this.goalCategory = goalCategory;
            this.confidence = confidence;
            this.message = message;
            this.allScores = allScores;
        }

        // Getters
        public boolean isVerified() { return verified; }
        public String getRecognizedCategory() { return recognizedCategory; }
        public String getGoalCategory() { return goalCategory; }
        public float getConfidence() { return confidence; }
        public String getMessage() { return message; }
        public Map<String, Double> getAllScores() { return allScores; }
    }
}
