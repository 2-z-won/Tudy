package com.example.tudy.friend;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import com.example.tudy.goal.Goal;
import com.example.tudy.goal.GoalRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
public class FriendshipService {
    private final FriendshipRepository friendshipRepository;
    private final UserRepository userRepository;
    private final GoalRepository goalRepository;

    public FriendshipService(FriendshipRepository friendshipRepository, UserRepository userRepository, GoalRepository goalRepository) {
        this.friendshipRepository = friendshipRepository;
        this.userRepository = userRepository;
        this.goalRepository = goalRepository;
    }

    @Transactional
    public boolean sendFriendRequest(String fromUserId, String toUserId) {
        Optional<User> fromUserOpt = userRepository.findByUserId(fromUserId);
        Optional<User> toUserOpt = userRepository.findByUserId(toUserId);
        if (fromUserOpt.isEmpty() || toUserOpt.isEmpty()) {
            return false;
        }
        User fromUser = fromUserOpt.get();
        User toUser = toUserOpt.get();
        if (friendshipRepository.existsByFromUserIdAndToUserIdAndStatus(fromUser.getId(), toUser.getId(), Friendship.Status.PENDING)) {
            return false;
        }
        Friendship friendship = new Friendship(fromUser, toUser, Friendship.Status.PENDING);
        friendshipRepository.save(friendship);
        return true;
    }

    public List<Friendship> getReceivedRequests(String userId) {
        Optional<User> userOpt = userRepository.findByUserId(userId);
        if (userOpt.isEmpty()) {
            return List.of();
        }
        return friendshipRepository.findByToUser_IdAndStatus(userOpt.get().getId(), Friendship.Status.PENDING);
    }

    @Transactional
    public boolean acceptRequest(Long requestId, String userId) {
        Optional<Friendship> requestOpt = friendshipRepository.findById(requestId);
        if (requestOpt.isEmpty()) return false;
        Friendship request = requestOpt.get();
        if (!request.getToUser().getUserId().equals(userId) || request.getStatus() != Friendship.Status.PENDING) return false;
        request.setStatus(Friendship.Status.ACCEPTED);
        friendshipRepository.save(request);
        return true;
    }

    @Transactional
    public boolean rejectRequest(Long requestId, String userId) {
        Optional<Friendship> requestOpt = friendshipRepository.findById(requestId);
        if (requestOpt.isEmpty()) return false;
        Friendship request = requestOpt.get();
        if (!request.getToUser().getUserId().equals(userId) || request.getStatus() != Friendship.Status.PENDING) return false;
        request.setStatus(Friendship.Status.REJECTED);
        friendshipRepository.save(request);
        return true;
    }

    public List<User> getFriends(String userId) {
        Optional<User> userOpt = userRepository.findByUserId(userId);
        if (userOpt.isEmpty()) {
            return List.of();
        }
        Long id = userOpt.get().getId();
        List<Friendship> friendships = friendshipRepository.findByFromUser_IdOrToUser_IdAndStatus(id, id, Friendship.Status.ACCEPTED);
        return friendships.stream().map(f -> {
            if (f.getFromUser().getId().equals(id)) return f.getToUser();
            else return f.getFromUser();
        }).toList();
    }

    public long getFriendCount(String userId) {
        return getFriends(userId).size();
    }

    public FriendsAndGoalsResponse getFriendsAndGoals(String userId) {
        Optional<User> userOpt = userRepository.findByUserId(userId);
        if (userOpt.isEmpty()) {
            return new FriendsAndGoalsResponse(List.of(), List.of());
        }
        
        // 친구 목록 조회
        List<User> friends = getFriends(userId);
        
        // 친구 목표 조회
        List<Goal> friendGoals = goalRepository.findByUserAndIsFriendGoalTrue(userOpt.get());
        
        return new FriendsAndGoalsResponse(friends, friendGoals);
    }

    public static class FriendsAndGoalsResponse {
        private List<User> friends;
        private List<Goal> friendGoals;

        public FriendsAndGoalsResponse(List<User> friends, List<Goal> friendGoals) {
            this.friends = friends;
            this.friendGoals = friendGoals;
        }

        // Getters and Setters
        public List<User> getFriends() { return friends; }
        public void setFriends(List<User> friends) { this.friends = friends; }
        
        public List<Goal> getFriendGoals() { return friendGoals; }
        public void setFriendGoals(List<Goal> friendGoals) { this.friendGoals = friendGoals; }
    }
} 
