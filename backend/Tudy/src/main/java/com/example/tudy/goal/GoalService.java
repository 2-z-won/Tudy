package com.example.tudy.goal;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import com.example.tudy.group.GroupMemberRepository;
import com.example.tudy.group.GroupMember;
import com.example.tudy.category.Category;
import com.example.tudy.category.CategoryRepository;
import com.example.tudy.study.StudySession;
import com.example.tudy.study.StudySessionRepository;
import com.example.tudy.game.CoinService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GoalService {
    private final GoalRepository goalRepository;
    private final UserRepository userRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final CategoryRepository categoryRepository;
    private final StudySessionRepository studySessionRepository;
    private final CoinService coinService;
    private static final int REWARD_COINS = 10;

    @Transactional
    public Goal createGoal(GoalCreateRequest request) {
        User user = userRepository.findByUserId(request.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + request.getUserId()));

        // targetTime 검증 추가
        if (request.getProofType() == Goal.ProofType.TIME && request.getTargetTime() != null) {
            if (request.getTargetTime() < 7200) { // 최소 2시간 (7200초)
                throw new IllegalArgumentException("목표 시간은 최소 2시간(7200초) 이상이어야 합니다.");
            }
        }

        Category category = getOrCreateCategory(user, request.getCategoryName());

        // 1. Goal 객체 생성
        Goal goal = new Goal();
        goal.setUser(user);
        goal.setTitle(request.getTitle());
        goal.setCategory(category);
        goal.setStartDate(request.getStartDate());
        goal.setEndDate(request.getEndDate());
        goal.setIsGroupGoal(request.getIsGroupGoal());
        goal.setGroupId(request.getGroupId());
        goal.setIsFriendGoal(request.getIsFriendGoal());
        goal.setFriendName(request.getFriendName());
        goal.setProofType(request.getProofType());
        goal.setTargetTime(request.getTargetTime());

        // 2. 기본 goal 즉시 저장
        goalRepository.save(goal);

        // 3. 그룹 목표가 있다면 저장
        if (Boolean.TRUE.equals(request.getIsGroupGoal()) && request.getGroupId() != null) {
            for (GroupMember member : groupMemberRepository.findAllByGroupId(request.getGroupId())) {
                if (!member.getUser().getId().equals(user.getId())) {
                    Category memberCategory = getOrCreateCategory(member.getUser(), request.getCategoryName());
                    Goal groupGoal = new Goal();
                    groupGoal.setUser(member.getUser());
                    groupGoal.setTitle(request.getTitle());
                    groupGoal.setCategory(memberCategory);
                    groupGoal.setStartDate(request.getStartDate());
                    groupGoal.setEndDate(request.getEndDate());
                    groupGoal.setIsGroupGoal(true);
                    groupGoal.setGroupId(request.getGroupId());
                    groupGoal.setIsFriendGoal(false);
                    groupGoal.setFriendName(null);
                    groupGoal.setProofType(request.getProofType());
                    groupGoal.setTargetTime(request.getTargetTime());
                    goalRepository.save(groupGoal);
                }
            }
        }

        // 4. 친구 목표가 있다면 저장
        if (Boolean.TRUE.equals(request.getIsFriendGoal()) && request.getFriendName() != null && !request.getFriendName().isBlank()) {
            userRepository.findByUserId(request.getFriendName()).ifPresent(friend -> {
                Category friendCategory = getOrCreateCategory(friend, request.getCategoryName());
                Goal friendGoal = new Goal();
                friendGoal.setUser(friend);
                friendGoal.setTitle(request.getTitle());
                friendGoal.setCategory(friendCategory);
                friendGoal.setStartDate(request.getStartDate());
                friendGoal.setEndDate(request.getEndDate());
                friendGoal.setIsGroupGoal(false);
                friendGoal.setGroupId(null);
                friendGoal.setIsFriendGoal(true);
                friendGoal.setFriendName(user.getUserId());
                friendGoal.setProofType(request.getProofType());
                friendGoal.setTargetTime(request.getTargetTime());
                goalRepository.save(friendGoal);
            });
        }

        // 5. 저장된 goal로부터 총 수행 시간 계산
        long totalDuration = getTotalDuration(goal);
        goal.setTotalDuration(totalDuration);

        // 시간 인증 목표는 설정된 목표 시간 이상이면 자동 완료
        if (request.getProofType() == Goal.ProofType.TIME && request.getTargetTime() != null && totalDuration >= request.getTargetTime()) {
            goal.setCompleted(true);
            // 목표 완료 시 새로운 코인 시스템으로 코인 지급
            if (goal.isCompleted()) {
                coinService.awardCoinsForGoalCompletion(user, category.getCategoryType());
            }
        }

        // 6. 최종 업데이트 후 반환
        return goalRepository.save(goal);
    }

    public Goal updateGoal(Long id, String title, String categoryName, LocalDate startDate, LocalDate endDate, Boolean isGroupGoal, Long groupId, Boolean isFriendGoal, String friendName, Goal.ProofType proofType, Integer targetTime) {
        Goal goal = goalRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Goal not found: " + id));
        
        // targetTime 검증 추가
        if (proofType == Goal.ProofType.TIME && targetTime != null) {
            if (targetTime < 7200) { // 최소 2시간 (7200초)
                throw new IllegalArgumentException("목표 시간은 최소 2시간(7200초) 이상이어야 합니다.");
            }
        }
        
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
            // 목표 완료 시 새로운 코인 시스템으로 코인 지급
            if (goal.isCompleted()) {
                coinService.awardCoinsForGoalCompletion(goal.getUser(), category.getCategoryType());
            }
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
        
        // 새로운 코인 시스템으로 코인 지급
        coinService.awardCoinsForGoalCompletion(goal.getUser(), goal.getCategory().getCategoryType());
        
        return goal;
    }

    private long getTotalDuration(Goal goal) {
        return studySessionRepository.findByGoal(goal).stream()
                .filter(s -> s.getDuration() != null)
                .mapToLong(StudySession::getDuration)
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

    public List<Goal> listGoalsByDate(String userId, LocalDate date, String categoryName) {
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

    // GoalCreateRequest DTO 클래스 추가
    @lombok.Data
    public static class GoalCreateRequest {
        private String userId;
        private String title;
        private String categoryName;
        private LocalDate startDate;
        private LocalDate endDate;
        private Boolean isGroupGoal;
        private Long groupId;
        private Boolean isFriendGoal;
        private String friendName;
        private Goal.ProofType proofType;
        private Integer targetTime;
    }
}