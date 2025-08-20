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
    @Operation(summary = "List goals by date grouped by category")
    @ApiResponse(responseCode = "200", description = "Goals grouped by category")
    public ResponseEntity<List<GoalGroupedByCategoryResponse>> listByDate(@RequestParam String userId, @RequestParam("date") String dateStr, @RequestParam(required = false) String categoryName) {
        LocalDate date = LocalDate.parse(dateStr);
        List<GoalGroupedByCategoryResponse> groupedGoals = goalService.listGoalsByDateGroupedByCategory(userId, date, categoryName);
        return ResponseEntity.ok(groupedGoals);
    }

    // 이미지 인증 목표의 proofImage 파일 업로드용 엔드포인트
    @PostMapping("/{id}/proof-image")
    @Operation(summary = "Upload proof image for image proof goal")
    @ApiResponse(responseCode = "200", description = "Proof image uploaded and goal completed")
    public ResponseEntity<Goal> uploadProofImage(@PathVariable Long id, @RequestParam("image") MultipartFile imageFile) {
        Goal goal = goalService.completeImageProofGoalWithFile(id, imageFile);
        return ResponseEntity.ok(goal);
    }

    @Data
    private static class GoalGroupedByCategoryResponse {
        @Schema(description = "Category information")
        private CategoryInfo category;
        @Schema(description = "List of goals in this category")
        private List<GoalInfo> goals;

        public GoalGroupedByCategoryResponse(CategoryInfo category, List<GoalInfo> goals) {
            this.category = category;
            this.goals = goals;
        }
    }

    @Data
    private static class CategoryInfo {
        @Schema(description = "Category ID", example = "1")
        private Long id;
        @Schema(description = "Category name", example = "공부")
        private String name;
        @Schema(description = "Category icon", example = "📚")
        private String icon;
        @Schema(description = "Category color", example = "1")
        private Integer color;
        @Schema(description = "Category type", example = "STUDY")
        private String categoryType;

        public CategoryInfo(com.example.tudy.category.Category category) {
            this.id = category.getId();
            this.name = category.getName();
            this.icon = category.getIcon();
            this.color = category.getColor();
            this.categoryType = category.getCategoryType() != null ? category.getCategoryType().name() : null;
        }
    }

    @Data
    private static class GoalInfo {
        @Schema(description = "Goal ID", example = "1")
        private Long id;
        @Schema(description = "Goal title", example = "스터디 목표")
        private String title;
        @Schema(description = "Start date", example = "2024-12-01")
        private String startDate;
        @Schema(description = "End date", example = "2024-12-31")
        private String endDate;
        @Schema(description = "Completion status", example = "false")
        private boolean completed;
        @Schema(description = "Proof image path", example = "/proof-images/...")
        private String proofImage;
        @Schema(description = "Group goal flag", example = "false")
        private Boolean isGroupGoal;
        @Schema(description = "Group ID", example = "1")
        private Long groupId;
        @Schema(description = "Friend goal flag", example = "false")
        private Boolean isFriendGoal;
        @Schema(description = "Friend name", example = "친구")
        private String friendName;
        @Schema(description = "Proof type", example = "TIME")
        private String proofType;
        @Schema(description = "Target time in seconds", example = "7200")
        private Integer targetTime;
        @Schema(description = "Total duration in seconds", example = "3600")
        private long totalDuration;

        public GoalInfo(Goal goal) {
            this.id = goal.getId();
            this.title = goal.getTitle();
            this.startDate = goal.getStartDate().toString();
            this.endDate = goal.getEndDate().toString();
            this.completed = goal.isCompleted();
            this.proofImage = goal.getProofImage();
            this.isGroupGoal = goal.getIsGroupGoal();
            this.groupId = goal.getGroupId();
            this.isFriendGoal = goal.getIsFriendGoal();
            this.friendName = goal.getFriendName();
            this.proofType = goal.getProofType() != null ? goal.getProofType().name() : null;
            this.targetTime = goal.getTargetTime();
            this.totalDuration = goal.getTotalDuration();
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