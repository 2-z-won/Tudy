package com.example.tudy.goal;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/goals")
@RequiredArgsConstructor
public class GoalController {
    private final GoalService goalService;

    @PostMapping
    public ResponseEntity<Goal> create(@RequestBody GoalRequest req) {
        Goal goal = goalService.createGoal(req.getUserId(), req.getTitle(), req.getCategoryName(), req.getStartDate(), req.getEndDate(), req.getIsGroupGoal(), req.getGroupId(), req.getIsFriendGoal(), req.getFriendNickname());
        return ResponseEntity.ok(goal);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Goal> update(@PathVariable Long id, @RequestBody GoalRequest req) {
        Goal goal = goalService.updateGoal(id, req.getTitle(), req.getCategoryName(), req.getStartDate(), req.getEndDate(), req.getIsGroupGoal(), req.getGroupId());
        return ResponseEntity.ok(goal);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        goalService.deleteGoal(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<Goal> complete(@PathVariable Long id, @RequestBody ProofRequest req) {
        Goal goal = goalService.completeGoal(id, req.getProofImage());
        return ResponseEntity.ok(goal);
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<Goal> cancel(@PathVariable Long id) {
        Goal goal = goalService.cancelCompletion(id);
        return ResponseEntity.ok(goal);
    }

    @GetMapping
    public ResponseEntity<List<Goal>> list(@RequestParam Long userId, @RequestParam(required = false) String categoryName) {
        return ResponseEntity.ok(goalService.listGoals(userId, categoryName));
    }

    @GetMapping("/by-date")
    public ResponseEntity<List<Goal>> listByDate(@RequestParam Long userId, @RequestParam("date") String dateStr, @RequestParam(required = false) String categoryName) {
        LocalDate date = LocalDate.parse(dateStr);
        return ResponseEntity.ok(goalService.listGoalsByDate(userId, date, categoryName));
    }

    @Data
    private static class GoalRequest {
        private Long userId;
        private String title;
        private String categoryName;
        private LocalDate startDate;
        private LocalDate endDate;
        private Boolean isGroupGoal;
        private Long groupId;
        private Boolean isFriendGoal;
        private String friendNickname;
    }

    @Data
    private static class ProofRequest {
        private String proofImage;
    }
}