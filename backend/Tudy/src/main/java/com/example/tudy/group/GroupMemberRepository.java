package com.example.tudy.group;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {
    boolean existsByUserAndGroup(User user, Group group);
    java.util.List<GroupMember> findAllByGroupId(Long groupId);
    java.util.List<GroupMember> findByUser(User user);
    boolean existsByUser(User user);
    
    // JOIN FETCH를 사용하여 Group과 Owner를 함께 로드
    @Query("SELECT gm FROM GroupMember gm JOIN FETCH gm.group g JOIN FETCH g.owner WHERE gm.user = :user")
    java.util.List<GroupMember> findByUserWithGroupAndOwner(@Param("user") User user);
} 