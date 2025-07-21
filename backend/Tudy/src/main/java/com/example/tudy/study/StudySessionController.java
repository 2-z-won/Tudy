package com.example.tudy.study;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/sessions")
@RequiredArgsConstructor
@Tag(name = "Study Session", description = "Study session APIs")
public class StudySessionController {
    private final StudySessionService service;

    @PostMapping("/log")
    @Operation(summary = "Log study time for a goal")
    @ApiResponse(responseCode = "200", description = "Session time logged successfully")
    public ResponseEntity<StudySession> log(@RequestBody LogRequest req) {
        StudySession session = service.logSession(req.getUserId(), req.getGoalId(), req.getHours(), req.getMinutes());
        return ResponseEntity.ok(session);
    }

    @GetMapping("/goal/{goalId}/duration")
    @Operation(summary = "Get total accumulated study duration for a goal")
    @ApiResponse(responseCode = "200", description = "Total duration in hours and minutes returned")
    public ResponseEntity<Map<String, Integer>> getDuration(@PathVariable Long goalId) {
        Integer totalSeconds = service.getAccumulatedDuration(goalId);
        int hours = totalSeconds / 3600;
        int minutes = (totalSeconds % 3600) / 60;
        return ResponseEntity.ok(Map.of("hours", hours, "minutes", minutes));
    }

    @GetMapping("/ranking")
    @Operation(summary = "Ranking by major")
    @ApiResponse(responseCode = "200", description = "Ranking returned")
    public ResponseEntity<Map<String, Long>> ranking() {
        return ResponseEntity.ok(service.rankingByMajor());
    }

    @Data
    private static class LogRequest {
        @Schema(description = "User ID", example = "1")
        private Long userId;
        @Schema(description = "Goal ID", example = "10")
        private Long goalId;
        @Schema(description = "Hours of study", example = "1")
        private Integer hours;
        @Schema(description = "Minutes of study", example = "30")
        private Integer minutes;
    }
}