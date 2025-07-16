package com.example.tudy.user;

import com.example.tudy.auth.TokenService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import com.example.tudy.friend.FriendshipService;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    private final TokenService tokenService;
    private final FriendshipService friendshipService;

    @PostMapping("/signup")
    public ResponseEntity<User> signUp(@RequestBody SignUpRequest request) {
        User user = userService.signUp(request.getEmail(), request.getUserId(), request.getPassword(), request.getName(), request.getBirth(), request.getCollege(), request.getMajor());
        return ResponseEntity.ok(user);
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody LoginRequest request) {
        return userService.login(request.getUserId(), request.getPassword())
                .map(u -> ResponseEntity.ok(Map.of("token", tokenService.generateToken(u.getId()))) )
                .orElseGet(() -> ResponseEntity.status(401).body(Map.of("error", "invalid")));
    }

    @PutMapping("/{id}/email")
    public ResponseEntity<?> changeEmail(@PathVariable Long id,
                                         @RequestBody EmailRequest request,
                                         @RequestHeader(value = "Authorization", required = false) String auth) {
        Long uid = tokenService.resolveUserId(auth);
        if (uid == null) {
            return ResponseEntity.status(401).build();
        }
        if (!uid.equals(id)) {
            return ResponseEntity.status(403).build();
        }
        if (request.getEmail() == null || !request.getEmail().matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            return ResponseEntity.badRequest().build();
        }
        if (userService.emailExists(request.getEmail())) {
            return ResponseEntity.status(409).body(Map.of("error", "Email already exists"));
        }
        User user = userService.updateEmail(id, request.getEmail());
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{id}/major")
    public ResponseEntity<?> changeMajor(@PathVariable Long id,
                                         @RequestBody ValueRequest request,
                                         @RequestHeader(value = "Authorization", required = false) String auth) {
        Long uid = tokenService.resolveUserId(auth);
        if (uid == null) return ResponseEntity.status(401).build();
        if (!uid.equals(id)) return ResponseEntity.status(403).build();
        User user = userService.updateMajor(id, request.getValue());
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{id}/college")
    public ResponseEntity<?> changeCollege(@PathVariable Long id,
                                           @RequestBody ValueRequest request,
                                           @RequestHeader(value = "Authorization", required = false) String auth) {
        Long uid = tokenService.resolveUserId(auth);
        if (uid == null) return ResponseEntity.status(401).build();
        if (!uid.equals(id)) return ResponseEntity.status(403).build();
        User user = userService.updateCollege(id, request.getValue());
        return ResponseEntity.ok(user);
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

    @GetMapping("/{id}")
    public ResponseEntity<UserWithFriendCountResponse> getUserWithFriendCount(@PathVariable Long id) {
        User user = userService.findById(id);
        // 친구 수 계산 (FriendshipService 사용)
        long friendCount = friendshipService.getFriendCount(id);
        UserWithFriendCountResponse response = new UserWithFriendCountResponse(user, friendCount);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/exists/userid")
    public ResponseEntity<Boolean> existsByUserId(@RequestParam String userId) {
        boolean exists = userService.userIdExists(userId);
        return ResponseEntity.ok(exists);
    }

    @Data
    private static class SignUpRequest {
        private String email;
        private String userId;
        private String password;
        private String name;
        private String birth;
        private String college;
        private String major;
    }

    @Data
    private static class LoginRequest {
        private String userId;
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

    @Data
    public static class UserWithFriendCountResponse {
        private Long id;
        private String email;
        private String name;
        private String major;
        private String college;
        private String profileImage;
        private Integer coinBalance;
        private long friendCount;

        public UserWithFriendCountResponse(User user, long friendCount) {
            this.id = user.getId();
            this.email = user.getEmail();
            this.name = user.getName();
            this.major = user.getMajor();
            this.college = user.getCollege();
            this.profileImage = user.getProfileImage();
            this.coinBalance = user.getCoinBalance();
            this.friendCount = friendCount;
        }
    }
}