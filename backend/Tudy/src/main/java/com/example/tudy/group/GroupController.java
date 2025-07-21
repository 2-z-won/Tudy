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
            Group group = groupService.createGroup(req.getName(), req.getPassword());
            return ResponseEntity.ok(group);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping
    @Operation(summary = "List groups")
    @ApiResponse(responseCode = "200", description = "Groups listed")
    public ResponseEntity<?> list(@RequestParam(name = "public") Boolean isPublic,
                                  @RequestParam(required = false) String password,
                                  @RequestParam(defaultValue = "0") int page,
                                  @RequestParam(defaultValue = "10") int size) {
        if (isPublic == null) {
            return ResponseEntity.badRequest().body("public parameter is required");
        }
        return ResponseEntity.ok(groupService.searchGroups(isPublic, password, page, size));
    }

    @PostMapping("/join")
    @Operation(summary = "Join group")
    @ApiResponse(responseCode = "200", description = "Joined")
    public ResponseEntity<String> join(@RequestBody JoinRequest req) {
        boolean success = groupService.joinGroup(req.getGroupId(), req.getUserId(), req.getPassword());
        if (success) {
            return ResponseEntity.ok("참여 성공");
        } else {
            return ResponseEntity.badRequest().body("비밀번호가 일치하지 않습니다.");
        }
    }

    @GetMapping("/exists")
    @Operation(summary = "Check group name")
    @ApiResponse(responseCode = "200", description = "Check completed")
    public ResponseEntity<Boolean> existsByName(@RequestParam String name) {
        return ResponseEntity.ok(groupService.existsByName(name));
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
        @Schema(description = "User ID", example = "2")
        private Long userId;
        @Schema(description = "Group password", example = "pass")
        private String password;
    }
} 