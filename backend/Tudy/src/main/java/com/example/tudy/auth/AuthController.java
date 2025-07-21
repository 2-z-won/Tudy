package com.example.tudy.auth;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Auth", description = "Authentication API")
public class AuthController {
    private final TokenService tokenService;
    private final JavaMailSender mailSender; // 추가
    private static final Map<String, String> emailCodeMap = new ConcurrentHashMap<>();
    private static final Random random = new Random();

    @PostMapping("/logout")
    @Operation(summary = "Logout")
    @ApiResponse(responseCode = "204", description = "Logged out")
    public ResponseEntity<Void> logout(@RequestHeader(value = "Authorization", required = false) String auth) {
        tokenService.blacklist(auth);
        return ResponseEntity.noContent().build();
    }

    // 이메일 인증번호 발송
    @PostMapping("/send-email")
    @Operation(summary = "Send email code")
    @ApiResponse(responseCode = "200", description = "Email sent")
    public Map<String, Object> sendEmail(@RequestBody Map<String, String> req) {
        String email = req.get("email");
        if (email == null || !email.endsWith("@pusan.ac.kr")) {
            return Map.of("success", false, "error", "부산대 이메일만 허용");
        }
        String code = String.format("%06d", random.nextInt(1000000));
        emailCodeMap.put(email, code);
        // 실제 이메일 발송
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
            helper.setTo(email);
            helper.setSubject("[Tudy] 부산대 이메일 인증번호 안내");
            helper.setText("인증번호는 " + code + " 입니다.", false);
            mailSender.send(message);
        } catch (MessagingException e) {
            return Map.of("success", false, "error", "이메일 발송 실패");
        }
        return Map.of("success", true);
    }

    // 이메일 인증번호 검증
    @PostMapping("/verify-email")
    @Operation(summary = "Verify email code")
    @ApiResponse(responseCode = "200", description = "Verified")
    public Map<String, Object> verifyEmail(@RequestBody Map<String, String> req) {
        String email = req.get("email");
        String code = req.get("code");
        String saved = emailCodeMap.get(email);
        if (saved != null && saved.equals(code)) {
            emailCodeMap.remove(email);
            return Map.of("success", true);
        } else {
            return Map.of("success", false, "error", "인증번호 불일치");
        }
    }
}
