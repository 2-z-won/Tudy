package com.example.tudy.goal;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import com.example.tudy.group.GroupMemberRepository;
import com.example.tudy.group.GroupMember;
import com.example.tudy.category.Category;
import com.example.tudy.category.CategoryRepository;
import com.example.tudy.study.StudySession;
import com.example.tudy.study.StudySessionRepository;
import jakarta.persistence.EntityNotFoundException;
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
    private final StudySessionRepository studySessionRepository;
    private static final int REWARD_COINS = 10;

    public Goal createGoal(String userId, String title, String categoryName, java.time.LocalDate startDate, java.time.LocalDate endDate, Boolean isGroupGoal, Long groupId, Boolean isFriendGoal, String friendName, Goal.ProofType proofType, Integer targetTime) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        Category category = getOrCreateCategory(user, categoryName);
        Goal goal = new Goal();
        goal.setUser(user);
        goal.setTitle(title);
        goal.setCategory(category);
        goal.setStartDate(startDate);
        goal.setEndDate(endDate);
        goal.setIsGroupGoal(isGroupGoal);
        goal.setGroupId(groupId);
        goal.setIsFriendGoal(isFriendGoal);
        goal.setFriendName(friendName);
        goal.setProofType(proofType);
        goal.setTargetTime(targetTime);
        // 시간 인증 목표는 설정된 목표 시간 이상이면 자동 완료
        if (proofType == Goal.ProofType.TIME && targetTime != null && getTotalDuration(goal) >= targetTime) {
            goal.setCompleted(true);
        }
        Goal savedGoal = goalRepository.save(goal);
        // 그룹 목표라면 그룹원 모두에게 동일 목표 생성
        if (Boolean.TRUE.equals(isGroupGoal) && groupId != null) {
            for (GroupMember member : groupMemberRepository.findAllByGroupId(groupId)) {
                if (!member.getUser().getId().equals(user.getId())) {
                    Category memberCategory = getOrCreateCategory(member.getUser(), categoryName);
                    Goal groupGoal = new Goal();
                    groupGoal.setUser(member.getUser());
                    groupGoal.setTitle(title);
                    groupGoal.setCategory(memberCategory);
                    groupGoal.setStartDate(startDate);
                    groupGoal.setEndDate(endDate);
                    groupGoal.setIsGroupGoal(true);
                    groupGoal.setGroupId(groupId);
                    groupGoal.setIsFriendGoal(false);
                    groupGoal.setFriendName(null);
                    groupGoal.setProofType(proofType);
                    groupGoal.setTargetTime(targetTime);
                    if (proofType == Goal.ProofType.TIME && targetTime != null && getTotalDuration(groupGoal) >= targetTime) {
                        groupGoal.setCompleted(true);
                    }
                    goalRepository.save(groupGoal);
                }
            }
        }
        // 친구와 함께하기 기능 (isFriendGoal이 true이고 friendName이 있을 때만)
        if (Boolean.TRUE.equals(isFriendGoal) && friendName != null && !friendName.isBlank()) {
            userRepository.findByUserId(friendName).ifPresent(friend -> {
                Category friendCategory = getOrCreateCategory(friend, categoryName);
                Goal friendGoal = new Goal();
                friendGoal.setUser(friend);
                friendGoal.setTitle(title);
                friendGoal.setCategory(friendCategory);
                friendGoal.setStartDate(startDate);
                friendGoal.setEndDate(endDate);
                friendGoal.setIsGroupGoal(false);
                friendGoal.setGroupId(null);
                friendGoal.setIsFriendGoal(true);
                friendGoal.setFriendName(user.getUserId());
                friendGoal.setProofType(proofType);
                friendGoal.setTargetTime(targetTime);
                if (proofType == Goal.ProofType.TIME && targetTime != null && getTotalDuration(friendGoal) >= targetTime) {
                    friendGoal.setCompleted(true);
                }
                goalRepository.save(friendGoal);
            });
        }
        return savedGoal;
    }

    public Goal updateGoal(Long id, String title, String categoryName, java.time.LocalDate startDate, java.time.LocalDate endDate, Boolean isGroupGoal, Long groupId, Boolean isFriendGoal, String friendName, Goal.ProofType proofType, Integer targetTime) {
        Goal goal = goalRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Goal not found: " + id));
        Category category = getOrCreateCategory(goal.getUser(), categoryName);
        goal.setTitle(title);
        goal.setCategory(category);
        goal.setStartDate(startDate);
        goal.setEndDate(endDate);
        goal.setIsGroupGoal(isGroupGoal);
        goal.setGroupId(groupId);
        goal.setIsFriendGoal(isFriendGoal);
        goal.setFriendName(friendName);
        goal.setProofType(proofType);
        goal.setTargetTime(targetTime);
        if (proofType == Goal.ProofType.TIME && targetTime != null && getTotalDuration(goal) >= targetTime) {
            goal.setCompleted(true);
        }
        Goal savedGoal = goalRepository.save(goal);
        return savedGoal;
    }

    public Goal deleteGoal(Long id) {
        Goal goal = goalRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Goal not found: " + id));
        goalRepository.delete(goal);
        return goal;
    }

    // 이미지 인증 목표의 proofImage 업로드 및 인증 처리
    public Goal completeImageProofGoal(Long id, String proofImage) {
        Goal goal = goalRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Goal not found: " + id));
        if (goal.getProofType() != Goal.ProofType.IMAGE) {
            throw new IllegalStateException("이미지 인증 목표가 아닙니다.");
        }
        if (proofImage == null || proofImage.isBlank()) {
            throw new IllegalArgumentException("이미지 경로가 필요합니다.");
        }
        goal.setProofImage(proofImage);
        goal.setCompleted(true);
        goalRepository.save(goal);
        userRepository.findById(goal.getUser().getId()).ifPresent(u -> {
            u.setCoinBalance(u.getCoinBalance() + REWARD_COINS);
            userRepository.save(u);
        });
        return goal;
    }

    private int getTotalDuration(Goal goal) {
        return studySessionRepository.findByGoal(goal).stream()
                .filter(s -> s.getDuration() != null)
                .mapToInt(StudySession::getDuration)
                .sum();
    }

    public List<Goal> listGoals(String userId, String categoryName) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        if (categoryName == null) {
            return goalRepository.findByUser(user);
        } else {
            Category category = categoryRepository.findByUserAndName(user, categoryName)
                    .orElseThrow(() -> new EntityNotFoundException("Category not found"));
            return goalRepository.findByUserAndCategory(user, category);
        }
    }

    public List<Goal> listGoalsByDate(String userId, java.time.LocalDate date, String categoryName) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        if (categoryName == null) {
            return goalRepository.findByUserAndStartDateLessThanEqualAndEndDateGreaterThanEqual(user, date, date);
        } else {
            Category category = categoryRepository.findByUserAndName(user, categoryName)
                    .orElseThrow(() -> new EntityNotFoundException("Category not found"));
            return goalRepository.findByUserAndStartDateLessThanEqualAndEndDateGreaterThanEqualAndCategory(user, date, date, category);
        }
    }

    public List<Goal> listGroupGoals(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        return goalRepository.findByUserAndIsGroupGoalTrue(user);
    }

    public List<Goal> listFriendGoals(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        return goalRepository.findByUserAndIsFriendGoalTrue(user);
    }

    private Category getOrCreateCategory(User user, String categoryName) {
        return categoryRepository.findByUserAndName(user, categoryName)
                .orElseGet(() -> {
                    Category category = new Category();
                    category.setUser(user);
                    category.setName(categoryName);
                    category.setColor(1); // 기본 색상(1)로 생성, 필요시 파라미터로 받을 수 있음
                    return categoryRepository.save(category);
                });
    }
}