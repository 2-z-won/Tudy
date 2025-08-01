package com.example.tudy.study;

import com.example.tudy.goal.Goal;
import com.example.tudy.goal.GoalRepository;
import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

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

    public StudySession logSession(String userId, Long goalId, Integer hours, Integer minutes) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        Goal goal = goalRepository.findById(goalId).orElseThrow();
        StudySession session = new StudySession();
        session.setUser(user);
        session.setGoal(goal);
        
        int durationInSeconds = (hours * 3600) + (minutes * 60);
        session.setDuration(durationInSeconds);
        session.setCreatedAt(LocalDateTime.now());
        return studySessionRepository.save(session);
    }

    public Integer getAccumulatedDuration(Long goalId) {
        return studySessionRepository.findTotalDurationByGoalId(goalId);
    }

    public Map<String, Long> rankingByMajor() {
        return studySessionRepository.totalDurationByMajor().stream()
                .collect(Collectors.toMap(r -> (String) r[0], r -> (Long) r[1]));
    }
}