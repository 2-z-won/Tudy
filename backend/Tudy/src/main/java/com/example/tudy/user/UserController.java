package com.example.tudy.user;

import com.example.tudy.auth.TokenService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;
import java.util.Map;
import com.example.tudy.friend.FriendshipService;
import java.util.NoSuchElementException;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "User", description = "Operations about users")
public class UserController {
    private final UserService userService;
    private final TokenService tokenService;
    private final FriendshipService friendshipService;

    private User getAuthenticatedUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || authentication.getName() == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증이 필요합니다.");
        }

        try {
            return userService.getUserByEmail(authentication.getName());
        } catch (NoSuchElementException e) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증정보가 유효하지 않습니다.");
        }
    }

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
                                         Authentication authentication) {
        User authenticatedUser = getAuthenticatedUser(authentication);
        User currentUser = userService.findByUserId(userId);
        if (!authenticatedUser.getId().equals(currentUser.getId())) return ResponseEntity.status(403).build();
        User user = userService.updateName(userId, request.getValue());
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{userId}/major")
    @Operation(summary = "Change major")
    @ApiResponse(responseCode = "200", description = "Major updated")
    public ResponseEntity<?> changeMajor(@PathVariable String userId,
                                         @RequestBody ValueRequest request,
                                         Authentication authentication) {
        User authenticatedUser = getAuthenticatedUser(authentication);
        User currentUser = userService.findByUserId(userId);
        if (!authenticatedUser.getId().equals(currentUser.getId())) return ResponseEntity.status(403).build();
        User user = userService.updateMajor(userId, request.getValue());
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{userId}/college")
    @Operation(summary = "Change college")
    @ApiResponse(responseCode = "200", description = "College updated")
    public ResponseEntity<?> changeCollege(@PathVariable String userId,
                                           @RequestBody ValueRequest request,
                                           Authentication authentication) {
        User authenticatedUser = getAuthenticatedUser(authentication);
        User currentUser = userService.findByUserId(userId);
        if (!authenticatedUser.getId().equals(currentUser.getId())) return ResponseEntity.status(403).build();
        User user = userService.updateCollege(userId, request.getValue());
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{userId}/birth")
    @Operation(summary = "Change birth")
    @ApiResponse(responseCode = "200", description = "Birth updated")
    public ResponseEntity<?> changeBirth(@PathVariable String userId,
                                         @RequestBody ValueRequest request,
                                         Authentication authentication) {
        User authenticatedUser = getAuthenticatedUser(authentication);
        User currentUser = userService.findByUserId(userId);
        if (!authenticatedUser.getId().equals(currentUser.getId())) return ResponseEntity.status(403).build();
        User user = userService.updateBirth(userId, request.getValue());
        return ResponseEntity.ok(user);
    }

    @PostMapping("/{userId}/password/verify")
    @Operation(summary = "Verify current password", description = "Verify the current password before changing it")
    @ApiResponse(responseCode = "200", description = "Password verified")
    @ApiResponse(responseCode = "400", description = "Invalid password")
    public ResponseEntity<?> verifyPassword(@PathVariable String userId,
                                          @RequestBody PasswordVerifyRequest request,
                                          Authentication authentication) {
        User authenticatedUser = getAuthenticatedUser(authentication);
        User currentUser = userService.findByUserId(userId);
        if (!authenticatedUser.getId().equals(currentUser.getId())) return ResponseEntity.status(403).build();
        
        boolean isValid = userService.verifyPassword(userId, request.getCurrentPassword());
        if (isValid) {
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid current password"));
        }
    }

    @PutMapping("/{userId}/password")
    @Operation(summary = "Change password", description = "Change password after verification")
    @ApiResponse(responseCode = "200", description = "Password updated")
    public ResponseEntity<?> changePassword(@PathVariable String userId,
                                          @RequestBody PasswordChangeRequest request,
                                          Authentication authentication) {
        User authenticatedUser = getAuthenticatedUser(authentication);
        User currentUser = userService.findByUserId(userId);
        if (!authenticatedUser.getId().equals(currentUser.getId())) return ResponseEntity.status(403).build();
        
        userService.updatePasswordWithoutVerification(userId, request.getNewPassword());
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{userId}/profile-image")
    @Operation(summary = "Change profile image")
    @ApiResponse(responseCode = "200", description = "Profile image updated")
    public ResponseEntity<User> changeProfileImage(@PathVariable String userId,
                                                   @RequestParam("image") MultipartFile imageFile,
                                                   Authentication authentication) {
        User authenticatedUser = getAuthenticatedUser(authentication);
        User currentUser = userService.findByUserId(userId);
        if (!authenticatedUser.getId().equals(currentUser.getId())) return ResponseEntity.status(403).build();
        User user = userService.updateProfileImageWithFile(userId, imageFile);
        return ResponseEntity.ok(user);
    }

    @GetMapping("/{userId}")
    @Operation(summary = "Get user info", description = "Retrieve user with friend count")
    @ApiResponse(responseCode = "200", description = "Found user")
    public ResponseEntity<UserWithFriendCountResponse> getUserWithFriendCount(@PathVariable String userId,
                                                                             Authentication authentication) {
        User authenticatedUser = getAuthenticatedUser(authentication);
        User user = userService.findByUserId(userId);
        if (!authenticatedUser.getId().equals(user.getId())) return ResponseEntity.status(403).build();
        long friendCount = friendshipService.getFriendCount(user.getUserId());
        UserWithFriendCountResponse response = new UserWithFriendCountResponse(user, friendCount);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{userId}/clean")
    @Operation(summary = "Clean user", description = "Spend 50 coins to remove dirty status")
    @ApiResponse(responseCode = "200", description = "User cleaned")
    public ResponseEntity<User> cleanUser(@PathVariable String userId,
                                          Authentication authentication) {
        User authenticatedUser = getAuthenticatedUser(authentication);
        User currentUser = userService.findByUserId(userId);
        if (!authenticatedUser.getId().equals(currentUser.getId())) return ResponseEntity.status(403).build();
        User cleaned = userService.cleanUser(userId);
        return ResponseEntity.ok(cleaned);
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
    private static class PasswordVerifyRequest {
        @Schema(description = "Current password to verify", example = "oldpass")
        private String currentPassword;
    }

    @Data
    private static class PasswordChangeRequest {
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
        @Schema(description = "Dirty status", example = "false")
        private boolean dirty;
        @Schema(description = "Last study date", example = "2024-06-01")
        private LocalDate lastStudyDate;

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
            this.dirty = user.isDirty();
            this.lastStudyDate = user.getLastStudyDate();
        }
    }
}