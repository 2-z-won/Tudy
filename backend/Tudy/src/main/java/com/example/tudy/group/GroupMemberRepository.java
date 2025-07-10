package com.example.tudy.group;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {
    boolean existsByUserAndGroup(User user, Group group);
} 