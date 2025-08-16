package com.example.tudy.user;

import com.example.tudy.auth.TokenService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
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

    @PutMapping("/{userId}/name")
    @Operation(summary = "Change name")
    @ApiResponse(responseCode = "200", description = "Name updated")
    public ResponseEntity<?> changeName(@PathVariable String userId,
                                         @RequestBody ValueRequest request,
                                         @RequestHeader(value = "Authorization", required = false) String auth) {
        Long uid = tokenService.resolveUserId(auth);
        if (uid == null) return ResponseEntity.status(401).build();
        User currentUser = userService.findByUserId(userId);
        if (!uid.equals(currentUser.getId())) return ResponseEntity.status(403).build();
        User user = userService.updateName(userId, request.getValue());
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{userId}/major")
    @Operation(summary = "Change major")
    @ApiResponse(responseCode = "200", description = "Major updated")
    public ResponseEntity<?> changeMajor(@PathVariable String userId,
                                         @RequestBody ValueRequest request,
                                         @RequestHeader(value = "Authorization", required = false) String auth) {
        Long uid = tokenService.resolveUserId(auth);
        if (uid == null) return ResponseEntity.status(401).build();
        User currentUser = userService.findByUserId(userId);
        if (!uid.equals(currentUser.getId())) return ResponseEntity.status(403).build();
        User user = userService.updateMajor(userId, request.getValue());
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{userId}/college")
    @Operation(summary = "Change college")
    @ApiResponse(responseCode = "200", description = "College updated")
    public ResponseEntity<?> changeCollege(@PathVariable String userId,
                                           @RequestBody ValueRequest request,
                                           @RequestHeader(value = "Authorization", required = false) String auth) {
        Long uid = tokenService.resolveUserId(auth);
        if (uid == null) return ResponseEntity.status(401).build();
        User currentUser = userService.findByUserId(userId);
        if (!uid.equals(currentUser.getId())) return ResponseEntity.status(403).build();
        User user = userService.updateCollege(userId, request.getValue());
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{userId}/password")
    @Operation(summary = "Change password")
    @ApiResponse(responseCode = "200", description = "Password updated")
    public ResponseEntity<Void> changePassword(@PathVariable String userId, @RequestBody PasswordRequest request) {
        userService.updatePassword(userId, request.getCurrentPassword(), request.getNewPassword());
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{userId}/profile-image")
    @Operation(summary = "Change profile image")
    @ApiResponse(responseCode = "200", description = "Profile image updated")
    public ResponseEntity<User> changeProfileImage(@PathVariable String userId, @RequestParam("image") MultipartFile imageFile) {
        User user = userService.updateProfileImageWithFile(userId, imageFile);
        return ResponseEntity.ok(user);
    }

    @GetMapping("/{userId}")
    @Operation(summary = "Get user info", description = "Retrieve user with friend count")
    @ApiResponse(responseCode = "200", description = "Found user")
    public ResponseEntity<UserWithFriendCountResponse> getUserWithFriendCount(@PathVariable String userId) {
        User user = userService.findByUserId(userId);
        // 친구 수 계산 (FriendshipService 사용)
        long friendCount = friendshipService.getFriendCount(user.getUserId());
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
        @Schema(description = "User ID", example = "user01")
        private String userId;
        @Schema(description = "Email", example = "user@pusan.ac.kr")
        private String email;
        @Schema(description = "Password (masked)", example = "********")
        private String password;
        @Schema(description = "Name", example = "홍길동")
        private String name;
        @Schema(description = "Birth date", example = "2000.01.01")
        private String birth;
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
            this.userId = user.getUserId();
            this.email = user.getEmail();
            this.password = "*".repeat(user.getPasswordHash().length());
            this.name = user.getName();
            this.birth = user.getBirth();
            this.major = user.getMajor();
            this.college = user.getCollege();
            this.profileImage = user.getProfileImage();
            this.coinBalance = user.getCoinBalance();
            this.friendCount = friendCount;
        }
    }
}