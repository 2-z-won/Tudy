package com.example.tudy.user;

import lombok.Data;
import lombok.RequiredArgsConstructor;
import com.example.tudy.auth.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    private final AuthService authService;

    @PostMapping("/signup")
    public ResponseEntity<User> signUp(@RequestBody SignUpRequest request) {
        User user = userService.signUp(request.getEmail(), request.getPassword(), request.getNickname(), request.getMajor());
        return ResponseEntity.ok(user);
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody LoginRequest request) {
        return userService.login(request.getEmail(), request.getPassword())
                .map(u -> ResponseEntity.ok(Map.of("token", authService.generateToken(u))))
                .orElseGet(() -> ResponseEntity.status(401).body(Map.of("error", "Invalid credentials")));
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

    @PutMapping("/{id}/email")
    public ResponseEntity<?> changeEmail(@PathVariable Long id, @RequestBody EmailRequest request,
                                         @RequestHeader("Authorization") String auth) {
        Long userId = authService.verify(auth);
        if (!userId.equals(id)) {
            return ResponseEntity.status(403).build();
        }
        if (request.getEmail() == null || !request.getEmail().contains("@")) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid email"));
        }
        try {
            User user = userService.updateEmail(id, request.getEmail());
            return ResponseEntity.ok(user);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(409).body(Map.of("error", "Email already exists"));
        }
    }

    @PutMapping("/{id}/major")
    public ResponseEntity<User> changeMajor(@PathVariable Long id, @RequestBody ValueRequest request,
                                            @RequestHeader("Authorization") String auth) {
        Long userId = authService.verify(auth);
        if (!userId.equals(id)) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(userService.updateMajor(id, request.getValue()));
    }

    @PutMapping("/{id}/college")
    public ResponseEntity<User> changeCollege(@PathVariable Long id, @RequestBody ValueRequest request,
                                              @RequestHeader("Authorization") String auth) {
        Long userId = authService.verify(auth);
        if (!userId.equals(id)) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(userService.updateCollege(id, request.getValue()));
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

    @Data
    private static class EmailRequest {
        private String email;
    }

    @Data
    private static class ValueRequest {
        private String value;
    }
}