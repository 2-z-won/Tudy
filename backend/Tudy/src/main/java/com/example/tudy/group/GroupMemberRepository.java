package com.example.tudy.group;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {
    boolean existsByUserAndGroup(User user, Group group);
    java.util.List<GroupMember> findAllByGroupId(Long groupId);
    java.util.List<GroupMember> findByUser(User user);
    boolean existsByUser(User user);
} 