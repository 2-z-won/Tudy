package com.example.tudy.goal;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import com.example.tudy.group.GroupMemberRepository;
import com.example.tudy.group.GroupMember;
import com.example.tudy.category.Category;
import com.example.tudy.category.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GoalService {
    private final GoalRepository goalRepository;
    private final UserRepository userRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final CategoryRepository categoryRepository;
    private static final int REWARD_COINS = 10;

    public Goal createGoal(Long userId, String title, String categoryName, java.time.LocalDate startDate, java.time.LocalDate endDate, Boolean isGroupGoal, Long groupId) {
        User user = userRepository.findById(userId).orElseThrow();
        Category category = getOrCreateCategory(user, categoryName);
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
                    Category memberCategory = getOrCreateCategory(member.getUser(), categoryName);
                    Goal groupGoal = new Goal();
                    groupGoal.setUser(member.getUser());
                    groupGoal.setTitle(title);
                    groupGoal.setCategory(memberCategory);
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

    public Goal updateGoal(Long id, String title, String categoryName, java.time.LocalDate startDate, java.time.LocalDate endDate, Boolean isGroupGoal, Long groupId) {
        Goal goal = goalRepository.findById(id).orElseThrow();
        Category category = getOrCreateCategory(goal.getUser(), categoryName);
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
                    Category memberCategory = getOrCreateCategory(member.getUser(), categoryName);
                    Goal groupGoal = new Goal();
                    groupGoal.setUser(member.getUser());
                    groupGoal.setTitle(title);
                    groupGoal.setCategory(memberCategory);
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

    public List<Goal> listGoals(Long userId, String categoryName) {
        User user = userRepository.findById(userId).orElseThrow();
        if (categoryName == null) {
            return goalRepository.findByUser(user);
        } else {
            Category category = categoryRepository.findByUserAndName(user, categoryName);
            if (category == null) return List.of();
            return goalRepository.findByUserAndCategory(user, category);
        }
    }

    public List<Goal> listGoalsByDate(Long userId, java.time.LocalDate date, String categoryName) {
        User user = userRepository.findById(userId).orElseThrow();
        if (categoryName == null) {
            return goalRepository.findByUserAndStartDateLessThanEqualAndEndDateGreaterThanEqual(user, date, date);
        } else {
            Category category = categoryRepository.findByUserAndName(user, categoryName);
            if (category == null) return List.of();
            return goalRepository.findByUserAndStartDateLessThanEqualAndEndDateGreaterThanEqualAndCategory(user, date, date, category);
        }
    }

    private Category getOrCreateCategory(User user, String categoryName) {
        Category category = categoryRepository.findByUserAndName(user, categoryName);
        if (category == null) {
            category = new Category();
            category.setUser(user);
            category.setName(categoryName);
            category.setColor(1); // 기본 색상(1)로 생성, 필요시 파라미터로 받을 수 있음
            category = categoryRepository.save(category);
        }
        return category;
    }
}