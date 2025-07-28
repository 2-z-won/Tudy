package com.example.tudy.group;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GroupJoinRequestRepository extends JpaRepository<GroupJoinRequest, Long> {

    // 특정 그룹의 대기중인 가입 신청만 조회
    List<GroupJoinRequest> findByGroupAndStatusOrderByCreatedAtDesc(Group group, GroupJoinRequest.RequestStatus status);

    // 특정 사용자가 특정 그룹에 이미 신청했는지 확인
    Optional<GroupJoinRequest> findByUserAndGroupAndStatus(User user, Group group, GroupJoinRequest.RequestStatus status);

    // 특정 사용자가 특정 그룹에 대기중인 신청이 있는지 확인
    boolean existsByUserAndGroupAndStatus(User user, Group group, GroupJoinRequest.RequestStatus status);
} 