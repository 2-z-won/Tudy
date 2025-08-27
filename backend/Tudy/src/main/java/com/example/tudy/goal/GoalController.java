package com.example.tudy.goal;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/goals")
@RequiredArgsConstructor
@Tag(name = "Goal", description = "Goal management APIs")
public class GoalController {
    private final GoalService goalService;

    @PostMapping
    @Operation(summary = "Create goal")
    @ApiResponse(responseCode = "200", description = "Goal created")
    public ResponseEntity<Goal> create(@RequestBody GoalService.GoalCreateRequest req) {
        Goal goal = goalService.createGoal(req);
        return ResponseEntity.ok(goal);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update goal")
    @ApiResponse(responseCode = "200", description = "Goal updated")
    public ResponseEntity<Goal> update(@PathVariable Long id, @RequestBody GoalUpdateRequest req) {
        Goal goal = goalService.updateGoal(id, req.getTitle(), req.getCategoryName(), req.getStartDate(), req.getEndDate(), req.getIsGroupGoal(), req.getGroupId(), req.getIsFriendGoal(), req.getFriendName(), req.getProofType(), req.getTargetTime());
        return ResponseEntity.ok(goal);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete goal")
    @ApiResponse(responseCode = "200", description = "Goal deleted")
    public ResponseEntity<Goal> delete(@PathVariable Long id) {
        Goal goal = goalService.deleteGoal(id);
        return ResponseEntity.ok(goal);
    }

    @GetMapping
    @Operation(summary = "List goals")
    @ApiResponse(responseCode = "200", description = "Goals listed")
    public ResponseEntity<List<Goal>> list(@RequestParam String userId, @RequestParam(required = false) String categoryName) {
        return ResponseEntity.ok(goalService.listGoals(userId, categoryName));
    }

    @GetMapping("/by-date")
    @Operation(summary = "List goals by date")
    @ApiResponse(responseCode = "200", description = "Goals listed")
    public ResponseEntity<List<Goal>> listByDate(@RequestParam String userId, @RequestParam("date") String dateStr, @RequestParam(required = false) String categoryName) {
        LocalDate date = LocalDate.parse(dateStr);
        return ResponseEntity.ok(goalService.listGoalsByDate(userId, date, categoryName));
    }

    // 이미지 인증 목표의 proofImage 파일 업로드용 엔드포인트
    @PostMapping("/{id}/proof-image")
    @Operation(summary = "Upload proof image for image proof goal")
    @ApiResponse(responseCode = "200", description = "Proof image uploaded and goal completed")
    public ResponseEntity<?> uploadProofImage(@PathVariable Long id, @RequestParam("image") MultipartFile imageFile) {
        try {
            GoalService.ImageProofResult result = goalService.completeImageProofGoalWithFile(id, imageFile);
            return ResponseEntity.ok(new ImageVerificationResponse(true, "이미지 인증이 완료되었습니다.", result.getGoal(), null, result.getConfidence()));
        } catch (ImageVerificationException e) {
            return ResponseEntity.badRequest()
                    .body(new ImageVerificationResponse(false, e.getMessage(), null, e.getErrorCode(), e.getConfidence()));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new ImageVerificationResponse(false, "이미지 처리 중 오류가 발생했습니다: " + e.getMessage(), null, "PROCESSING_ERROR", 0.0f));
        }
    }



    @Data
    private static class ImageVerificationResponse {
        private final boolean success;
        private final String message;
        private final Goal goal;
        private final String errorCode;
        private final float confidence;
        
        public ImageVerificationResponse(boolean success, String message, Goal goal, String errorCode, float confidence) {
            this.success = success;
            this.message = message;
            this.goal = goal;
            this.errorCode = errorCode;
            this.confidence = confidence;
        }
    }

    @Data
    private static class GoalUpdateRequest {
        @Schema(description = "Goal title", example = "스터디 목표")
        private String title;
        @Schema(description = "Category name", example = "공부")
        private String categoryName;
        @Schema(description = "Start date", example = "2024-01-01")
        private LocalDate startDate;
        @Schema(description = "End date", example = "2024-01-31")
        private LocalDate endDate;
        @Schema(description = "Group goal flag", example = "false")
        private Boolean isGroupGoal;
        @Schema(description = "Group ID", example = "1")
        private Long groupId;
        @Schema(description = "Friend goal flag", example = "false")
        private Boolean isFriendGoal;
        @Schema(description = "Friend name", example = "친구")
        private String friendName;
        @Schema(description = "Proof type", example = "TIME")
        private Goal.ProofType proofType;
        @Schema(description = "Target time in seconds", example = "7200")
        private Integer targetTime;
    }
}