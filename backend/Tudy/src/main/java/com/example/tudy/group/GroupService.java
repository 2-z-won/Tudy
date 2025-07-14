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
        Group group = new Group();
        group.setName(name);
        group.setPassword(password);
        return groupRepository.save(group);
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
} 