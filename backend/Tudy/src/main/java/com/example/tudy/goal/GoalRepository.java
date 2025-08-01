package com.example.tudy.goal;

import com.example.tudy.user.User;
import com.example.tudy.category.Category;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GoalRepository extends JpaRepository<Goal, Long> {
    List<Goal> findByUser(User user);
    List<Goal> findByUserAndCategory(User user, Category category);
    List<Goal> findByUserAndStartDateLessThanEqualAndEndDateGreaterThanEqual(User user, java.time.LocalDate date1, java.time.LocalDate date2);
    List<Goal> findByUserAndStartDateLessThanEqualAndEndDateGreaterThanEqualAndCategory(User user, java.time.LocalDate date1, java.time.LocalDate date2, Category category);
    
    // 사용자의 그룹 목표 조회
    List<Goal> findByUserAndIsGroupGoalTrue(User user);
    
    // 특정 그룹의 목표 조회
    List<Goal> findByGroupId(Long groupId);
    
    // 사용자의 친구 목표 조회
    List<Goal> findByUserAndIsFriendGoalTrue(User user);
}