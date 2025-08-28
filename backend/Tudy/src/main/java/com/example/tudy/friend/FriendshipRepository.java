package com.example.tudy.friend;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface FriendshipRepository extends JpaRepository<Friendship, Long> {
    
    // 받은 친구 신청 목록 조회 (JOIN FETCH로 fromUser와 toUser 정보 함께 로드)
    @Query("SELECT f FROM Friendship f JOIN FETCH f.fromUser JOIN FETCH f.toUser WHERE f.toUser.id = :toUserId AND f.status = :status")
    List<Friendship> findByToUser_IdAndStatus(@Param("toUserId") Long toUserId, @Param("status") Friendship.Status status);
    
    List<Friendship> findByFromUserIdAndStatus(Long fromUserId, Friendship.Status status);
    // ACCEPTED 상태의 친구 관계 조회 (JOIN FETCH로 fromUser와 toUser 정보 함께 로드)
    @Query("SELECT f FROM Friendship f JOIN FETCH f.fromUser JOIN FETCH f.toUser WHERE (f.fromUser.id = :fromUserId OR f.toUser.id = :fromUserId) AND f.status = :status")
    List<Friendship> findByFromUser_IdOrToUser_IdAndStatus(@Param("fromUserId") Long fromUserId, @Param("status") Friendship.Status status);
    List<Friendship> findByFromUserIdOrToUserId(Long fromUserId, Long toUserId);
    boolean existsByFromUserIdAndToUserIdAndStatus(Long fromUserId, Long toUserId, Friendship.Status status);
    Friendship findByFromUserIdAndToUserIdAndStatus(Long fromUserId, Long toUserId, Friendship.Status status);
} 
