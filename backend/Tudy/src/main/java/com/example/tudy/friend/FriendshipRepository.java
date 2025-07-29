package com.example.tudy.friend;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface FriendshipRepository extends JpaRepository<Friendship, Long> {
    List<Friendship> findByToUser_IdAndStatus(Long toUserId, Friendship.Status status);
    List<Friendship> findByFromUserIdAndStatus(Long fromUserId, Friendship.Status status);
    List<Friendship> findByFromUser_IdOrToUser_IdAndStatus(Long fromUserId, Long toUserId, Friendship.Status status);
    List<Friendship> findByFromUserIdOrToUserId(Long fromUserId, Long toUserId);
    boolean existsByFromUserIdAndToUserIdAndStatus(Long fromUserId, Long toUserId, Friendship.Status status);
    Friendship findByFromUserIdAndToUserIdAndStatus(Long fromUserId, Long toUserId, Friendship.Status status);
} 
