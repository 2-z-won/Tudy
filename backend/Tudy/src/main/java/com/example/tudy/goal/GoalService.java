package com.example.tudy.goal;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import com.example.tudy.group.GroupMemberRepository;
import com.example.tudy.group.GroupMember;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GoalService {
    private final GoalRepository goalRepository;
    private final UserRepository userRepository;
    private final GroupMemberRepository groupMemberRepository;
    private static final int REWARD_COINS = 10;

    public Goal createGoal(Long userId, String title, String category, java.time.LocalDate startDate, java.time.LocalDate endDate, Boolean isGroupGoal, Long groupId) {
        User user = userRepository.findById(userId).orElseThrow();
        Goal goal = new Goal();
        goal.setUser(user);
        goal.setTitle(title);
        goal.setCategory(category);
        goal.setStartDate(startDate);
        goal.setEndDate(endDate);
        goal.setIsGroupGoal(isGroupGoal);
        goal.setGroupId(groupId);
        Goal savedGoal = goalRepository.save(goal);
        // 그룹 목표라면 그룹원 모두에게 동일 목표 생성
        if (Boolean.TRUE.equals(isGroupGoal) && groupId != null) {
            for (GroupMember member : groupMemberRepository.findAllByGroupId(groupId)) {
                if (!member.getUser().getId().equals(userId)) {
                    Goal groupGoal = new Goal();
                    groupGoal.setUser(member.getUser());
                    groupGoal.setTitle(title);
                    groupGoal.setCategory(category);
                    groupGoal.setStartDate(startDate);
                    groupGoal.setEndDate(endDate);
                    groupGoal.setIsGroupGoal(true);
                    groupGoal.setGroupId(groupId);
                    goalRepository.save(groupGoal);
                }
            }
        }
        return savedGoal;
    }

    public Goal updateGoal(Long id, String title, String category, java.time.LocalDate startDate, java.time.LocalDate endDate, Boolean isGroupGoal, Long groupId) {
        Goal goal = goalRepository.findById(id).orElseThrow();
        goal.setTitle(title);
        goal.setCategory(category);
        goal.setStartDate(startDate);
        goal.setEndDate(endDate);
        goal.setIsGroupGoal(isGroupGoal);
        goal.setGroupId(groupId);
        Goal savedGoal = goalRepository.save(goal);
        // 그룹 목표라면 그룹원 모두에게 동일 목표 수정(간단화: 새로 생성)
        if (Boolean.TRUE.equals(isGroupGoal) && groupId != null) {
            for (GroupMember member : groupMemberRepository.findAllByGroupId(groupId)) {
                if (!member.getUser().getId().equals(goal.getUser().getId())) {
                    Goal groupGoal = new Goal();
                    groupGoal.setUser(member.getUser());
                    groupGoal.setTitle(title);
                    groupGoal.setCategory(category);
                    groupGoal.setStartDate(startDate);
                    groupGoal.setEndDate(endDate);
                    groupGoal.setIsGroupGoal(true);
                    groupGoal.setGroupId(groupId);
                    goalRepository.save(groupGoal);
                }
            }
        }
        return savedGoal;
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

    public List<Goal> listGoalsByDate(Long userId, java.time.LocalDate date) {
        User user = userRepository.findById(userId).orElseThrow();
        return goalRepository.findByUserAndStartDateLessThanEqualAndEndDateGreaterThanEqual(user, date, date);
    }
}