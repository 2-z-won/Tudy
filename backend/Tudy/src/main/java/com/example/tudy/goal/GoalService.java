package com.example.tudy.goal;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import com.example.tudy.group.GroupMemberRepository;
import com.example.tudy.group.GroupMember;
import com.example.tudy.category.Category;
import com.example.tudy.category.CategoryRepository;
import com.example.tudy.study.StudySession;
import com.example.tudy.study.StudySessionRepository;
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

    public Goal createGoal(Long userId, String title, String categoryName, java.time.LocalDate startDate, java.time.LocalDate endDate, Boolean isGroupGoal, Long groupId, Boolean isFriendGoal, String friendName, Goal.ProofType proofType) {
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
        goal.setIsFriendGoal(isFriendGoal);
        goal.setFriendName(friendName);
        goal.setProofType(proofType);
        // 시간 인증 목표는 누적 2시간 이상이면 자동 완료
        if (proofType == Goal.ProofType.TIME && getTotalDuration(goal) >= 7200) {
            goal.setCompleted(true);
        }
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
                    groupGoal.setIsFriendGoal(false);
                    groupGoal.setFriendName(null);
                    groupGoal.setProofType(proofType);
                    if (proofType == Goal.ProofType.TIME && getTotalDuration(groupGoal) >= 7200) {
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
                if (proofType == Goal.ProofType.TIME && getTotalDuration(friendGoal) >= 7200) {
                    friendGoal.setCompleted(true);
                }
                goalRepository.save(friendGoal);
            });
        }
        return savedGoal;
    }

    public Goal updateGoal(Long id, String title, String categoryName, java.time.LocalDate startDate, java.time.LocalDate endDate, Boolean isGroupGoal, Long groupId, Boolean isFriendGoal, String friendName, Goal.ProofType proofType) {
        Goal goal = goalRepository.findById(id).orElseThrow();
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
        if (proofType == Goal.ProofType.TIME && getTotalDuration(goal) >= 7200) {
            goal.setCompleted(true);
        }
        Goal savedGoal = goalRepository.save(goal);
        return savedGoal;
    }

    public Goal deleteGoal(Long id) {
        Goal goal = goalRepository.findById(id).orElseThrow();
        goalRepository.delete(goal);
        return goal;
    }

    // 이미지 인증 목표의 proofImage 업로드 및 인증 처리
    public Goal completeImageProofGoal(Long id, String proofImage) {
        Goal goal = goalRepository.findById(id).orElseThrow();
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

    public List<Goal> listGoalsByDate(String userId, java.time.LocalDate date, String categoryName) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        if (categoryName == null) {
            return goalRepository.findByUserAndStartDateLessThanEqualAndEndDateGreaterThanEqual(user, date, date);
        } else {
            Category category = categoryRepository.findByUserAndName(user, categoryName);
            if (category == null) return List.of();
            return goalRepository.findByUserAndStartDateLessThanEqualAndEndDateGreaterThanEqualAndCategory(user, date, date, category);
        }
    }

    public List<Goal> listGroupGoals(String userId) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        return goalRepository.findByUserAndIsGroupGoalTrue(user);
    }

    public List<Goal> listFriendGoals(String userId) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        return goalRepository.findByUserAndIsFriendGoalTrue(user);
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