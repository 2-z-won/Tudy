package com.example.tudy.user;

import com.example.tudy.auth.TokenService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Map;
import com.example.tudy.friend.FriendshipService;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "User", description = "Operations about users")
public class UserController {
    private final UserService userService;
    private final TokenService tokenService;
    private final FriendshipService friendshipService;

    @PostMapping("/signup")
    @Operation(summary = "Sign up", description = "Register a new user")
    @ApiResponse(responseCode = "200", description = "User created")
    public ResponseEntity<User> signUp(@RequestBody SignUpRequest request) {
        User user = userService.signUp(request.getEmail(), request.getUserId(), request.getPassword(), request.getName(), request.getBirth(), request.getCollege(), request.getMajor());
        return ResponseEntity.ok(user);
    }

    @PostMapping("/login")
    @Operation(summary = "Login", description = "Authenticate user and return token")
    @ApiResponse(responseCode = "200", description = "Authenticated")
    public ResponseEntity<Map<String, String>> login(@RequestBody LoginRequest request) {
        return userService.login(request.getUserId(), request.getPassword())
                .map(u -> ResponseEntity.ok(Map.of("token", tokenService.generateToken(u.getId()))) )
                .orElseGet(() -> ResponseEntity.status(401).body(Map.of("error", "invalid")));
    }

    @PutMapping("/{id}/email")
    @Operation(summary = "Change email")
    @ApiResponse(responseCode = "200", description = "Email updated")
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

    @PutMapping("/{id}/name")
    @Operation(summary = "Change name")
    @ApiResponse(responseCode = "200", description = "Name updated")
    public ResponseEntity<?> changeName(@PathVariable Long id,
                                         @RequestBody ValueRequest request,
                                         @RequestHeader(value = "Authorization", required = false) String auth) {
        Long uid = tokenService.resolveUserId(auth);
        if (uid == null) return ResponseEntity.status(401).build();
        if (!uid.equals(id)) return ResponseEntity.status(403).build();
        User user = userService.updateName(id, request.getValue());
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{id}/major")
    @Operation(summary = "Change major")
    @ApiResponse(responseCode = "200", description = "Major updated")
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
    @Operation(summary = "Change college")
    @ApiResponse(responseCode = "200", description = "College updated")
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
    @Operation(summary = "Change password")
    @ApiResponse(responseCode = "200", description = "Password updated")
    public ResponseEntity<Void> changePassword(@PathVariable Long id, @RequestBody PasswordRequest request) {
        userService.updatePassword(id, request.getCurrentPassword(), request.getNewPassword());
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{id}/profile-image")
    @Operation(summary = "Change profile image")
    @ApiResponse(responseCode = "200", description = "Profile image updated")
    public ResponseEntity<Void> changeProfileImage(@PathVariable Long id, @RequestBody ProfileImageRequest request) {
        userService.updateProfileImage(id, request.getImagePath());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get user info", description = "Retrieve user with friend count")
    @ApiResponse(responseCode = "200", description = "Found user")
    public ResponseEntity<UserWithFriendCountResponse> getUserWithFriendCount(@PathVariable Long id) {
        User user = userService.findById(id);
        // 친구 수 계산 (FriendshipService 사용)
        long friendCount = friendshipService.getFriendCount(id);
        UserWithFriendCountResponse response = new UserWithFriendCountResponse(user, friendCount);
        return ResponseEntity.ok(response);
    }

    @Data
    private static class SignUpRequest {
        @Schema(description = "Email address", example = "user@pusan.ac.kr")
        private String email;
        @Schema(description = "Login ID", example = "user01")
        private String userId;
        @Schema(description = "Password", example = "pass1234")
        private String password;
        @Schema(description = "User name", example = "홍길동")
        private String name;
        @Schema(description = "Birth date", example = "2000-01-01")
        private String birth;
        @Schema(description = "College name", example = "IT College")
        private String college;
        @Schema(description = "Major", example = "Computer Science")
        private String major;
    }

    @Data
    private static class LoginRequest {
        @Schema(description = "Login ID", example = "user01")
        private String userId;
        @Schema(description = "Password", example = "pass1234")
        private String password;
    }


    @Data
    private static class PasswordRequest {
        @Schema(description = "Current password", example = "oldpass")
        private String currentPassword;
        @Schema(description = "New password", example = "newpass")
        private String newPassword;
    }

    @Data
    private static class ProfileImageRequest {
        @Schema(description = "Image path", example = "/images/profile.png")
        private String imagePath;
    }

    @Data
    private static class EmailRequest {
        @Schema(description = "Email address", example = "user@pusan.ac.kr")
        private String email;
    }

    @Data
    private static class ValueRequest {
        @Schema(description = "Value", example = "example")
        private String value;
    }

    @Data
    public static class UserWithFriendCountResponse {
        @Schema(description = "User id", example = "1")
        private Long id;
        @Schema(description = "Email", example = "user@pusan.ac.kr")
        private String email;
        @Schema(description = "Name", example = "홍길동")
        private String name;
        @Schema(description = "Major", example = "Computer Science")
        private String major;
        @Schema(description = "College", example = "IT College")
        private String college;
        @Schema(description = "Profile image path", example = "/img.png")
        private String profileImage;
        @Schema(description = "Coin balance", example = "100")
        private Integer coinBalance;
        @Schema(description = "Number of friends", example = "5")
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