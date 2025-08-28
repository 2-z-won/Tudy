package com.example.tudy.group;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import com.example.tudy.goal.Goal;
import com.example.tudy.goal.GoalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GroupService {
    private final GroupRepository groupRepository;
    private final UserRepository userRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final GroupJoinRequestRepository groupJoinRequestRepository;
    private final GoalRepository goalRepository;

    public Group createGroup(String name, String password, Long ownerId) {
        User owner = userRepository.findById(ownerId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
        
        Group group = new Group();
        group.setName(name);
        group.setOwner(owner);
        
        if (password != null) {
            if (password.length() != 6) {
                throw new IllegalArgumentException("비밀번호는 6자리여야 합니다.");
            }
            group.setPassword(password);
        }
        
        Group savedGroup = groupRepository.save(group);
        
        // 그룹 생성자를 자동으로 멤버로 추가
        GroupMember ownerMember = new GroupMember(owner, savedGroup);
        groupMemberRepository.save(ownerMember);
        
        return savedGroup;
    }

    public boolean searchGroup(String name) {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }
        
        String trimmedName = name.trim();
        return groupRepository.existsByName(trimmedName);
    }

    @Transactional
    public String joinGroup(Long groupId, Long userId, String password) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("그룹을 찾을 수 없습니다."));
        
        // 비밀번호 확인
        if (!group.getPassword().equals(password)) {
            return "비밀번호가 일치하지 않습니다.";
        }
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
        
        // 이미 멤버인지 확인
        if (groupMemberRepository.existsByUserAndGroup(user, group)) {
            return "이미 그룹 멤버입니다.";
        }
        
        // 이미 대기중인 신청이 있는지 확인
        if (groupJoinRequestRepository.existsByUserAndGroupAndStatus(user, group, GroupJoinRequest.RequestStatus.PENDING)) {
            return "이미 가입 신청이 대기중입니다.";
        }
        
        // 가입 신청 생성
        GroupJoinRequest request = new GroupJoinRequest(user, group);
        groupJoinRequestRepository.save(request);
        
        return "가입 신청이 완료되었습니다.";
    }

    @Transactional
    public String approveJoinRequest(Long requestId, Long ownerId) {
        GroupJoinRequest request = groupJoinRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("가입 신청을 찾을 수 없습니다."));
        
        Group group = request.getGroup();
        
        // 그룹 소유자인지 확인
        if (!group.getOwner().getId().equals(ownerId)) {
            return "그룹 소유자만 승인할 수 있습니다.";
        }
        
        // 이미 처리된 신청인지 확인
        if (request.getStatus() != GroupJoinRequest.RequestStatus.PENDING) {
            return "이미 처리된 신청입니다.";
        }
        
        // 승인 처리
        request.setStatus(GroupJoinRequest.RequestStatus.APPROVED);
        groupJoinRequestRepository.save(request);
        
        // 그룹 멤버로 추가
        GroupMember member = new GroupMember(request.getUser(), group);
        groupMemberRepository.save(member);
        
        return "가입 신청이 승인되었습니다.";
    }

    @Transactional
    public String rejectJoinRequest(Long requestId, Long ownerId) {
        GroupJoinRequest request = groupJoinRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("가입 신청을 찾을 수 없습니다."));
        
        Group group = request.getGroup();
        
        // 그룹 소유자인지 확인
        if (!group.getOwner().getId().equals(ownerId)) {
            return "그룹 소유자만 거부할 수 있습니다.";
        }
        
        // 이미 처리된 신청인지 확인
        if (request.getStatus() != GroupJoinRequest.RequestStatus.PENDING) {
            return "이미 처리된 신청입니다.";
        }
        
        // 거부 처리
        request.setStatus(GroupJoinRequest.RequestStatus.REJECTED);
        groupJoinRequestRepository.save(request);
        
        return "가입 신청이 거부되었습니다.";
    }

    public List<GroupJoinRequest> getPendingRequests(Long groupId, Long ownerId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("그룹을 찾을 수 없습니다."));
        
        // 그룹 소유자인지 확인
        if (!group.getOwner().getId().equals(ownerId)) {
            throw new IllegalArgumentException("그룹 소유자만 신청 목록을 볼 수 있습니다.");
        }
        
        return groupJoinRequestRepository.findByGroupAndStatusOrderByCreatedAtDesc(group, GroupJoinRequest.RequestStatus.PENDING);
    }

    // 사용자의 그룹 목록 조회 메서드 추가
    public List<Group> getUserGroups(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
        
        return groupMemberRepository.findByUser(user).stream()
                .map(GroupMember::getGroup)
                .toList();
    }

    // 사용자의 그룹과 그룹 목표 함께 조회
    public GroupsAndGoalsResponse getUserGroupsAndGoals(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        List<Group> groups = getUserGroups(userId);
        List<Goal> groupGoals = goalRepository.findByUserAndIsGroupGoalTrue(user);
        
        return new GroupsAndGoalsResponse(groups, groupGoals);
    }

    // 응답 DTO 클래스
    public static class GroupsAndGoalsResponse {
        private List<Group> groups;
        private List<Goal> groupGoals;

        public GroupsAndGoalsResponse(List<Group> groups, List<Goal> groupGoals) {
            this.groups = groups;
            this.groupGoals = groupGoals;
        }

        // Getters and Setters
        public List<Group> getGroups() { return groups; }
        public void setGroups(List<Group> groups) { this.groups = groups; }
        
        public List<Goal> getGroupGoals() { return groupGoals; }
        public void setGroupGoals(List<Goal> groupGoals) { this.groupGoals = groupGoals; }
    }
} 