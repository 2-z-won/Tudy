package com.example.tudy.group;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.server.ResponseStatusException;

import com.example.tudy.auth.TokenService;

@RestController
@RequestMapping("/api/groups")
@RequiredArgsConstructor
@Tag(name = "Group", description = "Group management APIs")
public class GroupController {
    private final GroupService groupService;
    private final TokenService tokenService;

    private Long getAuthenticatedUserId(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            Long userId = tokenService.resolveUserId(authHeader.substring(7));
            if (userId != null) {
                return userId;
            }
        }
        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증이 필요합니다.");
    }

    @PostMapping
    @Operation(summary = "Create group")
    @ApiResponse(responseCode = "200", description = "Group created")
    public ResponseEntity<?> create(@RequestBody GroupRequest req, HttpServletRequest request) {
        try {
            Long userId = getAuthenticatedUserId(request);
            Group group = groupService.createGroup(req.getName(), req.getPassword(), userId);
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
    public ResponseEntity<String> join(@RequestBody JoinRequest req, HttpServletRequest request) {
        try {
            Long userId = getAuthenticatedUserId(request);
            String result = groupService.joinGroup(req.getGroupId(), userId, req.getPassword());
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/{requestId}/approve")
    @Operation(summary = "Approve join request")
    @ApiResponse(responseCode = "200", description = "Join request approved")
    public ResponseEntity<String> approveRequest(@PathVariable Long requestId, HttpServletRequest request) {
        try {
            Long userId = getAuthenticatedUserId(request);
            String result = groupService.approveJoinRequest(requestId, userId);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/{requestId}/reject")
    @Operation(summary = "Reject join request")
    @ApiResponse(responseCode = "200", description = "Join request rejected")
    public ResponseEntity<String> rejectRequest(@PathVariable Long requestId, HttpServletRequest request) {
        try {
            Long userId = getAuthenticatedUserId(request);
            String result = groupService.rejectJoinRequest(requestId, userId);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/{groupId}/pending-requests")
    @Operation(summary = "Get pending join requests")
    @ApiResponse(responseCode = "200", description = "Pending requests listed")
    public ResponseEntity<?> getPendingRequests(@PathVariable Long groupId, HttpServletRequest request) {
        try {
            Long userId = getAuthenticatedUserId(request);
            return ResponseEntity.ok(groupService.getPendingRequests(groupId, userId));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 사용자의 그룹 정보와 그룹 목표 조회
    @GetMapping("/user")
    @Operation(summary = "Get user groups and group goals")
    @ApiResponse(responseCode = "200", description = "User groups and goals retrieved")
    public ResponseEntity<GroupService.GroupsAndGoalsResponse> getUserGroupsAndGoals(HttpServletRequest request) {
        try {
            Long userId = getAuthenticatedUserId(request);
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
    }

    @Data
    private static class JoinRequest {
        @Schema(description = "Group ID", example = "1")
        private Long groupId;
        @Schema(description = "Group password", example = "pass")
        private String password;
    }
}