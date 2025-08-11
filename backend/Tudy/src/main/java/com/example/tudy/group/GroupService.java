package com.example.tudy.group;

import com.example.tudy.goal.Goal;
import com.example.tudy.goal.GoalRepository;
import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
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

    public Group createGroup(String name, String password, String ownerId) {
        User owner = userRepository.findByUserId(ownerId)
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
    public String joinGroup(Long groupId, String userId, String password) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("그룹을 찾을 수 없습니다."));
        
        // 비밀번호 확인
        if (!group.getPassword().equals(password)) {
            return "비밀번호가 일치하지 않습니다.";
        }
        
        User user = userRepository.findByUserId(userId)
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
    public String approveJoinRequest(Long requestId, Long groupId, String ownerId) {
        GroupJoinRequest request = groupJoinRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("가입 신청을 찾을 수 없습니다."));
        
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("그룹을 찾을 수 없습니다."));
        
        // 그룹 소유자인지 확인
        if (!group.getOwner().getUserId().equals(ownerId)) {
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
    public String rejectJoinRequest(Long requestId, Long groupId, String ownerId) {
        GroupJoinRequest request = groupJoinRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("가입 신청을 찾을 수 없습니다."));
        
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("그룹을 찾을 수 없습니다."));
        
        // 그룹 소유자인지 확인
        if (!group.getOwner().getUserId().equals(ownerId)) {
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

    public List<GroupJoinRequest> getPendingRequests(Long groupId, String ownerId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new IllegalArgumentException("그룹을 찾을 수 없습니다."));
        
        // 그룹 소유자인지 확인
        if (!group.getOwner().getUserId().equals(ownerId)) {
            throw new IllegalArgumentException("그룹 소유자만 신청 목록을 볼 수 있습니다.");
        }
        
        return groupJoinRequestRepository.findByGroupAndStatusOrderByCreatedAtDesc(group, GroupJoinRequest.RequestStatus.PENDING);
    }

    public UserGroupsAndGoalsResponse getUserGroupsAndGoals(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
        
        // 사용자의 그룹 정보 조회
        List<GroupMember> memberships = groupMemberRepository.findByUser(user);
        List<GroupInfo> groups = memberships.stream()
                .map(membership -> {
                    Group group = membership.getGroup();
                    return new GroupInfo(
                            group.getId(),
                            group.getName()
                    );
                })
                .toList();
        
        // 사용자의 그룹 목표 조회
        List<Goal> groupGoals = goalRepository.findByUserAndIsGroupGoalTrue(user);
        
        return new UserGroupsAndGoalsResponse(groups, groupGoals);
    }

    public static class GroupInfo {
        private Long id;
        private String name;

        public GroupInfo(Long id, String name) {
            this.id = id;
            this.name = name;
        }

        // Getters and Setters
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
    }

    public static class UserGroupsAndGoalsResponse {
        private List<GroupInfo> groups;
        private List<Goal> groupGoals;

        public UserGroupsAndGoalsResponse(List<GroupInfo> groups, List<Goal> groupGoals) {
            this.groups = groups;
            this.groupGoals = groupGoals;
        }

        // Getters and Setters
        public List<GroupInfo> getGroups() { return groups; }
        public void setGroups(List<GroupInfo> groups) { this.groups = groups; }
        
        public List<Goal> getGroupGoals() { return groupGoals; }
        public void setGroupGoals(List<Goal> groupGoals) { this.groupGoals = groupGoals; }
    }
} 