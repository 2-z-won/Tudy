package com.example.tudy.goal;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GoalService {
    private final GoalRepository goalRepository;
    private final UserRepository userRepository;
    private static final int REWARD_COINS = 10;

    public Goal createGoal(Long userId, String title, String category, java.time.LocalDate startDate, java.time.LocalDate endDate) {
        User user = userRepository.findById(userId).orElseThrow();
        Goal goal = new Goal();
        goal.setUser(user);
        goal.setTitle(title);
        goal.setCategory(category);
        goal.setStartDate(startDate);
        goal.setEndDate(endDate);
        return goalRepository.save(goal);
    }

    public Goal updateGoal(Long id, String title, String category, java.time.LocalDate startDate, java.time.LocalDate endDate) {
        Goal goal = goalRepository.findById(id).orElseThrow();
        goal.setTitle(title);
        goal.setCategory(category);
        goal.setStartDate(startDate);
        goal.setEndDate(endDate);
        return goalRepository.save(goal);
    }

    public void deleteGoal(Long id) {
        goalRepository.deleteById(id);
    }

    public Goal completeGoal(Long id, String proofImage) {
        Goal goal = goalRepository.findById(id).orElseThrow();
        goal.setCompleted(true);
        goal.setProofImage(proofImage);
        goalRepository.save(goal);
        userRepository.findById(goal.getUser().getId()).ifPresent(u -> {
            u.setCoinBalance(u.getCoinBalance() + REWARD_COINS);
            userRepository.save(u);
        });
        return goal;
    }

    public Goal cancelCompletion(Long id) {
        Goal goal = goalRepository.findById(id).orElseThrow();
        goal.setCompleted(false);
        goal.setProofImage(null);
        return goalRepository.save(goal);
    }

    public List<Goal> listGoals(Long userId, String category) {
        User user = userRepository.findById(userId).orElseThrow();
        if (category == null) {
            return goalRepository.findByUser(user);
        } else {
            return goalRepository.findByUserAndCategory(user, category);
        }
    }
}