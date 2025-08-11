package com.example.tudy.group;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.media.Schema;

@RestController
@RequestMapping("/api/groups")
@RequiredArgsConstructor
@Tag(name = "Group", description = "Group management APIs")
public class GroupController {
    private final GroupService groupService;

    @PostMapping
    @Operation(summary = "Create group")
    @ApiResponse(responseCode = "200", description = "Group created")
    public ResponseEntity<?> create(@RequestBody GroupRequest req) {
        try {
            Group group = groupService.createGroup(req.getName(), req.getPassword(), req.getOwnerId());
            return ResponseEntity.ok(group);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/search")
    @Operation(summary = "Search group")
    @ApiResponse(responseCode = "200", description = "Group found")
    public ResponseEntity<Boolean> searchGroup(@RequestParam String name) {
        boolean exists = groupService.searchGroup(name);
        return ResponseEntity.ok(exists);
    }

    @PostMapping("/join")
    @Operation(summary = "Join group")
    @ApiResponse(responseCode = "200", description = "Join request submitted")
    public ResponseEntity<String> join(@RequestBody JoinRequest req) {
        try {
            String result = groupService.joinGroup(req.getGroupId(), req.getUserId(), req.getPassword());
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/{requestId}/approve")
    @Operation(summary = "Approve join request")
    @ApiResponse(responseCode = "200", description = "Join request approved")
    public ResponseEntity<String> approveRequest(@PathVariable Long requestId, 
                                               @RequestParam String ownerId) {
        try {
            String result = groupService.approveJoinRequest(requestId, ownerId);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/{requestId}/reject")
    @Operation(summary = "Reject join request")
    @ApiResponse(responseCode = "200", description = "Join request rejected")
    public ResponseEntity<String> rejectRequest(@PathVariable Long requestId, 
                                              @RequestParam String ownerId) {
        try {
            String result = groupService.rejectJoinRequest(requestId, ownerId);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/{groupId}/pending-requests")
    @Operation(summary = "Get pending join requests")
    @ApiResponse(responseCode = "200", description = "Pending requests listed")
    public ResponseEntity<?> getPendingRequests(@PathVariable Long groupId, 
                                              @RequestParam String ownerId) {
        try {
            return ResponseEntity.ok(groupService.getPendingRequests(groupId, ownerId));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 사용자의 그룹 정보와 그룹 목표 조회
    @GetMapping("/user/{userId}")
    @Operation(summary = "Get user groups and group goals")
    @ApiResponse(responseCode = "200", description = "User groups and goals retrieved")
    public ResponseEntity<GroupService.GroupsAndGoalsResponse> getUserGroupsAndGoals(@PathVariable String userId) {
        try {
            GroupService.GroupsAndGoalsResponse response = groupService.getUserGroupsAndGoals(userId);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    @Data
    private static class GroupRequest {
        @Schema(description = "Group name", example = "스터디1")
        private String name;
        @Schema(description = "Password", example = "pass")
        private String password;
        @Schema(description = "Owner ID", example = "test")
        private String ownerId;
    }

    @Data
    private static class JoinRequest {
        @Schema(description = "Group ID", example = "1")
        private Long groupId;
        @Schema(description = "User ID", example = "user1")
        private String userId;
        @Schema(description = "Group password", example = "pass")
        private String password;
    }
} 