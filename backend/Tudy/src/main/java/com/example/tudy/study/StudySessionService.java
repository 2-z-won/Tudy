package com.example.tudy.study;

import com.example.tudy.goal.Goal;
import com.example.tudy.goal.GoalRepository;
import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StudySessionService {
    private final StudySessionRepository studySessionRepository;
    private final UserRepository userRepository;
    private final GoalRepository goalRepository;

    public StudySession startSession(Long userId, Long goalId) {
        User user = userRepository.findById(userId).orElseThrow();
        Goal goal = goalRepository.findById(goalId).orElseThrow();
        StudySession session = new StudySession();
        session.setUser(user);
        session.setGoal(goal);
        session.setStartTime(LocalDateTime.now());
        return studySessionRepository.save(session);
    }

    public StudySession endSession(Long sessionId) {
        StudySession session = studySessionRepository.findById(sessionId).orElseThrow();
        session.setEndTime(LocalDateTime.now());
        session.setDuration((int) Duration.between(session.getStartTime(), session.getEndTime()).getSeconds());
        return studySessionRepository.save(session);
    }

    public Map<String, Long> rankingByMajor() {
        return studySessionRepository.totalDurationByMajor().stream()
                .collect(Collectors.toMap(r -> (String) r[0], r -> (Long) r[1]));
    }

    public List<StudySession> sessionsForGoal(Long goalId) {
        Goal goal = goalRepository.findById(goalId).orElseThrow();
        return studySessionRepository.findByGoal(goal);
    }
}