package com.example.tudy.study;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/sessions")
@RequiredArgsConstructor
public class StudySessionController {
    private final StudySessionService service;

    @PostMapping("/start")
    public ResponseEntity<StudySession> start(@RequestBody StartRequest req) {
        StudySession session = service.startSession(req.getUserId(), req.getGoalId());
        return ResponseEntity.ok(session);
    }

    @PostMapping("/{id}/end")
    public ResponseEntity<StudySession> end(@PathVariable Long id) {
        return ResponseEntity.ok(service.endSession(id));
    }

    @GetMapping("/ranking")
    public ResponseEntity<Map<String, Long>> ranking() {
        return ResponseEntity.ok(service.rankingByMajor());
    }

    @GetMapping("/goal/{goalId}")
    public ResponseEntity<List<StudySession>> sessions(@PathVariable Long goalId) {
        return ResponseEntity.ok(service.sessionsForGoal(goalId));
    }

    @Data
    private static class StartRequest {
        private Long userId;
        private Long goalId;
    }
}