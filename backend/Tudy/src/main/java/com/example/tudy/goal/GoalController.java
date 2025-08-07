package com.example.tudy.goal;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
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
    public ResponseEntity<Goal> create(@RequestBody GoalRequest req) {
        Goal goal = goalService.createGoal(req.getUserId(), req.getTitle(), req.getCategoryName(), req.getStartDate(), req.getEndDate(), req.getIsGroupGoal(), req.getGroupId(), req.getIsFriendGoal(), req.getFriendName(), req.getProofType(), req.getTargetTime());
        return ResponseEntity.ok(goal);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update goal")
    @ApiResponse(responseCode = "200", description = "Goal updated")
    public ResponseEntity<Goal> update(@PathVariable Long id, @RequestBody GoalRequest req) {
        Goal goal = goalService.updateGoal(id, req.getTitle(), req.getCategoryName(), req.getStartDate(), req.getEndDate(), req.getIsGroupGoal(), req.getGroupId(), req.getIsFriendGoal(), req.getFriendName(), req.getProofType(), req.getTargetTime());
        return ResponseEntity.ok(goal);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete goal")
    @ApiResponse(responseCode = "200", description = "Goal deleted")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        goalService.deleteGoal(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping
    @Operation(summary = "List goals")
    @ApiResponse(responseCode = "200", description = "Goals listed")
    public ResponseEntity<List<Goal>> list(@RequestParam Long userId, @RequestParam(required = false) String categoryName) {
        return ResponseEntity.ok(goalService.listGoals(userId, categoryName));
    }

    @GetMapping("/by-date")
    @Operation(summary = "List goals by date")
    @ApiResponse(responseCode = "200", description = "Goals listed")
    public ResponseEntity<List<Goal>> listByDate(@RequestParam String userId, @RequestParam("date") String dateStr, @RequestParam(required = false) String categoryName) {
        LocalDate date = LocalDate.parse(dateStr);
        return ResponseEntity.ok(goalService.listGoalsByDate(userId, date, categoryName));
    }

    @GetMapping("/group")
    @Operation(summary = "List group goals")
    @ApiResponse(responseCode = "200", description = "Group goals listed")
    public ResponseEntity<List<SimpleGoalResponse>> listGroupGoals(@RequestParam String userId) {
        List<Goal> goals = goalService.listGroupGoals(userId);
        List<SimpleGoalResponse> result = goals.stream()
            .map(goal -> new SimpleGoalResponse(goal.getTitle(), goal.isCompleted()))
            .toList();
        return ResponseEntity.ok(result);
    }

    @GetMapping("/friend")
    @Operation(summary = "List friend goals")
    @ApiResponse(responseCode = "200", description = "Friend goals listed")
    public ResponseEntity<List<SimpleGoalResponse>> listFriendGoals(@RequestParam String userId) {
        List<Goal> goals = goalService.listFriendGoals(userId);
        List<SimpleGoalResponse> result = goals.stream()
            .map(goal -> new SimpleGoalResponse(goal.getTitle(), goal.isCompleted(), goal.getFriendName()))
            .toList();
        return ResponseEntity.ok(result);
    }

    // 이미지 인증 목표의 proofImage 업로드용 엔드포인트 예시 (실제 파일 업로드는 별도 구현 필요)
    @PostMapping("/{id}/proof-image")
    @Operation(summary = "Upload proof image for image proof goal")
    @ApiResponse(responseCode = "200", description = "Proof image uploaded and goal completed")
    public ResponseEntity<Goal> uploadProofImage(@PathVariable Long id, @RequestBody ProofRequest req) {
        Goal goal = goalService.completeImageProofGoal(id, req.getProofImage());
        return ResponseEntity.ok(goal);
    }

    @Data
    private static class GoalRequest {
        @Schema(description = "User ID", example = "1")
        private String userId;
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

    @Data
    private static class ProofRequest {
        @Schema(description = "Proof image path", example = "/proof.png")
        private String proofImage;
    }

    @Data
    class SimpleGoalResponse {
        @Schema(description = "Goal title", example = "목표명")
        private String title;
        @Schema(description = "Completion status", example = "false")
        private boolean completed;
        @Schema(description = "Friend name", example = "김철수")
        private String friendName;

        public SimpleGoalResponse(String title, boolean completed) {
            this.title = title;
            this.completed = completed;
        }

        public SimpleGoalResponse(String title, boolean completed, String friendName) {
            this.title = title;
            this.completed = completed;
            this.friendName = friendName;
        }
    }
}