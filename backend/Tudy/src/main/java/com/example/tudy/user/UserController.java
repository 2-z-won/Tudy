package com.example.tudy.user;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PostMapping("/signup")
    public ResponseEntity<User> signUp(@RequestBody SignUpRequest request) {
        User user = userService.signUp(request.getEmail(), request.getPassword(), request.getNickname(), request.getMajor());
        return ResponseEntity.ok(user);
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody LoginRequest request) {
        return userService.login(request.getEmail(), request.getPassword())
                .map(u -> ResponseEntity.ok(Map.of("status", "success")))
                .orElseGet(() -> ResponseEntity.status(401).body(Map.of("status", "fail")));
    }

    @PutMapping("/{id}/nickname")
    public ResponseEntity<Void> changeNickname(@PathVariable Long id, @RequestBody NicknameRequest request) {
        userService.updateNickname(id, request.getNickname());
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{id}/password")
    public ResponseEntity<Void> changePassword(@PathVariable Long id, @RequestBody PasswordRequest request) {
        userService.updatePassword(id, request.getCurrentPassword(), request.getNewPassword());
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{id}/profile-image")
    public ResponseEntity<Void> changeProfileImage(@PathVariable Long id, @RequestBody ProfileImageRequest request) {
        userService.updateProfileImage(id, request.getImagePath());
        return ResponseEntity.ok().build();
    }

    @Data
    private static class SignUpRequest {
        private String email;
        private String password;
        private String nickname;
        private String major;
    }

    @Data
    private static class LoginRequest {
        private String email;
        private String password;
    }

    @Data
    private static class NicknameRequest {
        private String nickname;
    }

    @Data
    private static class PasswordRequest {
        private String currentPassword;
        private String newPassword;
    }

    @Data
    private static class ProfileImageRequest {
        private String imagePath;
    }
}