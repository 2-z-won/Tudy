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
import com.example.tudy.ai.ClipImageClassificationService;
import com.example.tudy.ai.CategoryMappingService;
import com.example.tudy.service.S3FileService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class GoalService {
    private final GoalRepository goalRepository;
    private final UserRepository userRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final CategoryRepository categoryRepository;
    private final StudySessionRepository studySessionRepository;
    private final CoinService coinService;
    private final ClipImageClassificationService clipImageClassificationService;
    private final CategoryMappingService categoryMappingService;
    private final S3FileService s3FileService;
    private static final int REWARD_COINS = 10;

    // 카페 카테고리 자동 생성 메서드
    @Transactional
    public void ensureCafeCategoryExists(User user) {
        if (!categoryRepository.existsByUserAndName(user, "카페")) {
            Category cafeCategory = new Category();
            cafeCategory.setUser(user);
            cafeCategory.setName("카페");
            cafeCategory.setIcon("☕");
            cafeCategory.setColor(10);
            cafeCategory.setCategoryType(null); // type = null
            categoryRepository.save(cafeCategory);
        }
    }

    // 카페 목표 자동 생성 메서드
    @Transactional
    public void createDailyCafeGoal(User user) {
        LocalDate today = LocalDate.now();
        
        // 오늘 날짜에 이미 카페 목표가 있는지 확인
        List<Goal> todayGoals = goalRepository.findByUserAndStartDateLessThanEqualAndEndDateGreaterThanEqual(
            user, today, today);
        
        boolean hasCafeGoalToday = todayGoals.stream()
            .anyMatch(goal -> "카페".equals(goal.getCategory().getName()) && 
                             "커피 한잔만 마시기".equals(goal.getTitle()));
        
        if (!hasCafeGoalToday) {
            // 카페 카테고리 확인 및 생성
            ensureCafeCategoryExists(user);
            
            Category cafeCategory = categoryRepository.findByUserAndName(user, "카페")
                .orElseThrow(() -> new IllegalStateException("카페 카테고리를 찾을 수 없습니다."));
            
            // 카페 목표 생성
            Goal cafeGoal = new Goal();
            cafeGoal.setUser(user);
            cafeGoal.setTitle("커피 한잔만 마시기");
            cafeGoal.setCategory(cafeCategory);
            cafeGoal.setStartDate(today);
            cafeGoal.setEndDate(today);
            cafeGoal.setIsGroupGoal(false);
            cafeGoal.setGroupId(null);
            cafeGoal.setIsFriendGoal(false);
            cafeGoal.setFriendName(null);
            cafeGoal.setProofType(Goal.ProofType.IMAGE);
            cafeGoal.setTargetTime(null);
            cafeGoal.setCompleted(false);
            
            goalRepository.save(cafeGoal);
        }
    }

    // 모든 사용자에 대해 카페 목표 자동 생성 (스케줄러용)
    @Transactional
    public void createDailyCafeGoalsForAllUsers() {
        List<User> allUsers = userRepository.findAll();
        for (User user : allUsers) {
            createDailyCafeGoal(user);
        }
    }

    // 이미지 인증 결과를 담는 내부 클래스
    public static class ImageProofResult {
        private final Goal goal;
        private final float confidence;
        
        public ImageProofResult(Goal goal, float confidence) {
            this.goal = goal;
            this.confidence = confidence;
        }
        
        public Goal getGoal() { return goal; }
        public float getConfidence() { return confidence; }
    }

    // 이미지 파일 업로드 및 목표 완료 처리 (AI 인증 포함)
    @Transactional
    public ImageProofResult completeImageProofGoalWithFile(Long id, MultipartFile imageFile) {
        Goal goal = goalRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Goal not found: " + id));
        
        if (goal.getProofType() != Goal.ProofType.IMAGE) {
            throw new IllegalStateException("이미지 인증 목표가 아닙니다.");
        }
        
        if (imageFile == null || imageFile.isEmpty()) {
            throw new IllegalArgumentException("이미지 파일이 필요합니다.");
        }
        
        // 이미지 파일 검증
        String contentType = imageFile.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("이미지 파일만 업로드 가능합니다.");
        }
        
        try {
            // CLIP을 사용한 이미지 분류 및 카테고리 매칭
            byte[] imageBytes = imageFile.getBytes();
            String goalCategoryName = goal.getCategory().getName();
            
            // 기본 카테고리로 분류
            List<String> categories = List.of("공부", "운동", "카페");
            ClipImageClassificationService.ClipClassificationResult clipResult;
            
            clipResult = clipImageClassificationService.classifyImage(imageBytes, categories);
            
            CategoryMappingService.CategoryMatchResult matchResult = 
                    categoryMappingService.matchCategory(clipResult, goalCategoryName);
            
            // 신뢰도 검증
            if (!categoryMappingService.isConfidentEnough(clipResult.getConfidence())) {
                throw new ImageVerificationException(
                    String.format("이미지 분석 신뢰도가 낮습니다. (신뢰도: %.1f%%) 더 명확한 사진을 업로드해주세요.", 
                    clipResult.getConfidence() * 100),
                    "LOW_CONFIDENCE",
                    clipResult.getConfidence());
            }
            
            // 카테고리 매칭 검증
            if (!matchResult.isMatches()) {
                throw new ImageVerificationException(matchResult.getMessage(), "CATEGORY_MISMATCH", 
                    clipResult.getConfidence());
            }
            
            // 인증 성공 - S3에 파일 저장
            String imageUrl = s3FileService.uploadFile(imageFile, "proof-images");
            
            // Goal에 이미지 URL 저장
            goal.setProofImage(imageUrl);
            goal.setCompleted(true);
            
            Goal savedGoal = goalRepository.save(goal);
            
            // 새로운 코인 시스템으로 코인 지급
            coinService.awardCoinsForGoalCompletion(goal.getUser(), goal.getCategory().getCategoryType());
            
            return new ImageProofResult(savedGoal, clipResult.getConfidence());
            
        } catch (IOException e) {
            throw new RuntimeException("이미지 파일 저장 중 오류가 발생했습니다: " + e.getMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException("이미지 파일 처리 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
    }

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

    // 이미지 인증 목표의 proofImage 업로드 및 인증 처리 (기존 메서드 - URL 방식)
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
            return goalRepository.findByUserWithCategory(user);
        } else {
            Category category = categoryRepository.findByUserAndName(user, categoryName)
                    .orElseThrow(() -> new EntityNotFoundException("Category not found"));
            return goalRepository.findByUserAndCategory(user, category);
        }
    }

    public List<Goal> listGoalsByDate(String userId, LocalDate date, String categoryName) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        
        // 카페 목표 자동 생성 (해당 날짜에 대해)
        createDailyCafeGoal(user);
        
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