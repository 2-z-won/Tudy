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
        Goal goal = goalService.createGoal(req.getUserId(), req.getTitle(), req.getCategoryName(), req.getStartDate(), req.getEndDate(), req.getIsGroupGoal(), req.getGroupId(), req.getIsFriendGoal(), req.getFriendName());
        return ResponseEntity.ok(goal);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update goal")
    @ApiResponse(responseCode = "200", description = "Goal updated")
    public ResponseEntity<Goal> update(@PathVariable Long id, @RequestBody GoalRequest req) {
        Goal goal = goalService.updateGoal(id, req.getTitle(), req.getCategoryName(), req.getStartDate(), req.getEndDate(), req.getIsGroupGoal(), req.getGroupId(), req.getIsFriendGoal(), req.getFriendName());
        return ResponseEntity.ok(goal);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete goal")
    @ApiResponse(responseCode = "200", description = "Goal deleted")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        goalService.deleteGoal(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/complete")
    @Operation(summary = "Complete goal")
    @ApiResponse(responseCode = "200", description = "Goal completed")
    public ResponseEntity<Goal> complete(@PathVariable Long id,
                                         @RequestBody(required = false) ProofRequest req) {
        String img = req != null ? req.getProofImage() : null;
        Goal goal = goalService.completeGoal(id, img);
        return ResponseEntity.ok(goal);
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "Cancel completion")
    @ApiResponse(responseCode = "200", description = "Completion canceled")
    public ResponseEntity<Goal> cancel(@PathVariable Long id) {
        Goal goal = goalService.cancelCompletion(id);
        return ResponseEntity.ok(goal);
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
    public ResponseEntity<List<Goal>> listByDate(@RequestParam Long userId, @RequestParam("date") String dateStr, @RequestParam(required = false) String categoryName) {
        LocalDate date = LocalDate.parse(dateStr);
        return ResponseEntity.ok(goalService.listGoalsByDate(userId, date, categoryName));
    }

    @Data
    private static class GoalRequest {
        @Schema(description = "User ID", example = "1")
        private Long userId;
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
    }

    @Data
    private static class ProofRequest {
        @Schema(description = "Proof image path", example = "/proof.png")
        private String proofImage;
    }
}