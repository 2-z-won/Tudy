package com.example.tudy.group;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/groups")
@RequiredArgsConstructor
public class GroupController {
    private final GroupService groupService;

    @GetMapping
    public ResponseEntity<List<Group>> list(@RequestParam("public") boolean isPublic,
                                            @RequestParam(required = false) String password) {
        return ResponseEntity.ok(groupService.listGroups(isPublic, password));
    }

    @PostMapping
    public ResponseEntity<Group> create(@RequestBody GroupRequest req) {
        Group group = groupService.createGroup(req.getName(), req.isPrivate(), req.getPassword());
        return ResponseEntity.ok(group);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Group> update(@PathVariable Long id, @RequestBody GroupRequest req) {
        Group group = groupService.updateGroup(id, req.getName(), req.isPrivate(), req.getPassword());
        return ResponseEntity.ok(group);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        groupService.deleteGroup(id);
        return ResponseEntity.ok().build();
    }

    @Data
    private static class GroupRequest {
        private String name;
        private boolean isPrivate;
        private String password;
    }
}
