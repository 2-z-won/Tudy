package com.example.tudy.group;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/groups")
@RequiredArgsConstructor
public class GroupController {
    private final GroupService groupService;

    @PostMapping
    public ResponseEntity<?> create(@RequestBody GroupRequest req) {
        try {
            Group group = groupService.createGroup(req.getName(), req.getPassword());
            return ResponseEntity.ok(group);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/join")
    public ResponseEntity<String> join(@RequestBody JoinRequest req) {
        boolean success = groupService.joinGroup(req.getGroupId(), req.getUserId(), req.getPassword());
        if (success) {
            return ResponseEntity.ok("참여 성공");
        } else {
            return ResponseEntity.badRequest().body("비밀번호가 일치하지 않습니다.");
        }
    }

    @GetMapping("/exists")
    public ResponseEntity<Boolean> existsByName(@RequestParam String name) {
        return ResponseEntity.ok(groupService.existsByName(name));
    }

    @Data
    private static class GroupRequest {
        private String name;
        private String password;
    }

    @Data
    private static class JoinRequest {
        private Long groupId;
        private Long userId;
        private String password;
    }
} 