package com.example.tudy.goal;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/goals")
@RequiredArgsConstructor
@Validated
@Tag(name = "Goal", description = "Goal management APIs")
public class GoalController {
    private final GoalService goalService;

    @PostMapping
    @Operation(summary = "Create goal")
    @ApiResponse(responseCode = "200", description = "Goal created")
    public ResponseEntity<Goal> create(@Valid @RequestBody GoalCreateRequest req) {
        Goal goal = goalService.createGoal(req);
        return ResponseEntity.ok(goal);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update goal")
    @ApiResponse(responseCode = "200", description = "Goal updated")
    public ResponseEntity<Goal> update(@PathVariable Long id, @Valid @RequestBody GoalCreateRequest req) {
        Goal goal = goalService.updateGoal(
                id,
                req.getTitle(),
                req.getCategoryName(),
                req.getStartDate(),
                req.getEndDate(),
                req.getIsGroupGoal(),
                req.getGroupId(),
                req.getIsFriendGoal(),
                req.getFriendName(),
                req.getProofType(),
                req.getTargetTime()
        );
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
    public ResponseEntity<Goal> uploadProofImage(@PathVariable Long id, @Valid @RequestBody ProofRequest req) {
        Goal goal = goalService.completeImageProofGoal(id, req.getProofImage());
        return ResponseEntity.ok(goal);
    }

    @Data
    private static class ProofRequest {
        @Schema(description = "Proof image path", example = "/proof.png")
        @NotBlank
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