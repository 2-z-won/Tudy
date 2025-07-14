package com.example.tudy.group;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/groups")
@RequiredArgsConstructor
public class GroupController {
    private final GroupService groupService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> list(@RequestParam("public") boolean isPublic,
                                                    @RequestParam(required = false) String password,
                                                    @RequestParam(defaultValue = "0") int page,
                                                    @RequestParam(defaultValue = "10") int size) {
        var result = groupService.search(isPublic, password, org.springframework.data.domain.PageRequest.of(page, size));
        return ResponseEntity.ok(Map.of(
                "content", result.getContent(),
                "page", result.getNumber(),
                "size", result.getSize(),
                "totalElements", result.getTotalElements()
        ));
    }

    @PostMapping
    public ResponseEntity<Group> create(@RequestBody GroupRequest req) {
        Group group = groupService.createGroup(req.getName(), req.getPassword());
        return ResponseEntity.ok(group);
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