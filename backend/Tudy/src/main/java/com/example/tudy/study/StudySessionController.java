package com.example.tudy.study;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/sessions")
@RequiredArgsConstructor
@Tag(name = "Study Session", description = "Study session APIs")
public class StudySessionController {
    private final StudySessionService service;

    @PostMapping("/start")
    @Operation(summary = "Start study session")
    @ApiResponse(responseCode = "200", description = "Session started")
    public ResponseEntity<StudySession> start(@RequestBody StartRequest req) {
        StudySession session = service.startSession(req.getUserId(), req.getGoalId());
        return ResponseEntity.ok(session);
    }

    @PostMapping("/{id}/end")
    @Operation(summary = "End study session")
    @ApiResponse(responseCode = "200", description = "Session ended")
    public ResponseEntity<StudySession> end(@PathVariable Long id) {
        return ResponseEntity.ok(service.endSession(id));
    }

    @GetMapping("/ranking")
    @Operation(summary = "Ranking by major")
    @ApiResponse(responseCode = "200", description = "Ranking returned")
    public ResponseEntity<Map<String, Long>> ranking() {
        return ResponseEntity.ok(service.rankingByMajor());
    }

    @GetMapping("/goal/{goalId}")
    @Operation(summary = "Sessions for goal")
    @ApiResponse(responseCode = "200", description = "Sessions returned")
    public ResponseEntity<List<StudySession>> sessions(@PathVariable Long goalId) {
        return ResponseEntity.ok(service.sessionsForGoal(goalId));
    }

    @Data
    private static class StartRequest {
        @Schema(description = "User ID", example = "1")
        private Long userId;
        @Schema(description = "Goal ID", example = "10")
        private Long goalId;
    }
}