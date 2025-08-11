package com.example.tudy.friend;

import com.example.tudy.user.User;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/friends")
public class FriendshipController {
    private final FriendshipService friendshipService;

    public FriendshipController(FriendshipService friendshipService) {
        this.friendshipService = friendshipService;
    }

    @PostMapping("/request") // 친구 신청
    public Map<String, Boolean> sendFriendRequest(@RequestParam String userId, @RequestParam String toUserId) {
        boolean result = friendshipService.sendFriendRequest(userId, toUserId);
        return Map.of("success", result);
    }

    @GetMapping("/requests") // 받은 친구신청 목록 조회
    public List<Friendship> getReceivedRequests(@RequestParam String userId) {
        return friendshipService.getReceivedRequests(userId);
    }

    @PostMapping("/request/{id}/accept") // 친구 신청 승인
    public Map<String, Boolean> acceptRequest(@PathVariable Long id, @RequestParam String userId) {
        boolean result = friendshipService.acceptRequest(id, userId);
        return Map.of("success", result);
    }

    @PostMapping("/request/{id}/reject") // 친구 신청 거부
    public Map<String, Boolean> rejectRequest(@PathVariable Long id, @RequestParam String userId) {
        boolean result = friendshipService.rejectRequest(id, userId);
        return Map.of("success", result);
    }

    @GetMapping("/{userId}") // 친구 목록과 친구 목표 함께 조회
    public FriendshipService.FriendsAndGoalsResponse getFriendsAndGoals(@PathVariable String userId) {
        return friendshipService.getFriendsAndGoals(userId);
    }
} 