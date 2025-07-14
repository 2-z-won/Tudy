package com.example.tudy.group;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class GroupService {
    private final GroupRepository groupRepository;
    private final UserRepository userRepository;
    private final GroupMemberRepository groupMemberRepository;

    public Group createGroup(String name, String password) {
        if (groupRepository.existsByName(name)) {
            throw new IllegalArgumentException("이미 존재하는 그룹 이름입니다.");
        }
        Group group = new Group();
        group.setName(name);
        if (password != null) {
            if (password.length() != 6) {
                throw new IllegalArgumentException("비밀번호는 6자리여야 합니다.");
            }
            group.setPrivate(true);
            group.setPassword(password);
        }
        return groupRepository.save(group);
    }

    public org.springframework.data.domain.Page<Group> searchGroups(boolean isPublic, String password, int page, int size) {
        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(page, size);
        if (isPublic) {
            return groupRepository.findByIsPrivateFalse(pageable);
        } else {
            if (password == null) {
                return org.springframework.data.domain.Page.empty(pageable);
            }
            return groupRepository.findByIsPrivateTrueAndPassword(password, pageable);
        }
    }

    @Transactional
    public boolean joinGroup(Long groupId, Long userId, String password) {
        Group group = groupRepository.findById(groupId).orElseThrow();
        if (!group.getPassword().equals(password)) {
            return false;
        }
        User user = userRepository.findById(userId).orElseThrow();
        if (!groupMemberRepository.existsByUserAndGroup(user, group)) {
            GroupMember member = new GroupMember();
            member.setUser(user);
            member.setGroup(group);
            groupMemberRepository.save(member);
        }
        return true;
    }

    public boolean existsByName(String name) {
        return groupRepository.existsByName(name);
    }
} 