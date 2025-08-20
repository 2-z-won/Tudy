package com.example.tudy.user;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Optional;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    
    // 프로필 이미지 저장 경로 설정
    private static final String PROFILE_IMAGE_UPLOAD_DIR = "uploads/profile-images/";
    private static final String PROFILE_IMAGE_URL_PREFIX = "/profile-images/";

    public User signUp(String email, String userId, String password, String name, String birth, String college, String major) {
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("Email already exists");
        }
        if (userRepository.findByUserId(userId).isPresent()) {
            throw new IllegalArgumentException("UserId already exists");
        }
        if (userRepository.findByName(name).isPresent()) {
            throw new IllegalArgumentException("Name already exists");
        }
        User user = new User();
        user.setEmail(email);
        user.setUserId(userId);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setName(name);
        user.setBirth(birth);
        user.setCollege(college);
        user.setMajor(major);
        user.setCoinBalance(0);
        return userRepository.save(user);
    }

    public Optional<User> login(String userId, String password) {
        return userRepository.findByUserId(userId)
                .filter(u -> passwordEncoder.matches(password, u.getPasswordHash()));
    }

    public boolean emailExists(String email) {
        return userRepository.findByEmail(email).isPresent();
    }

    public User updateEmail(String userId, String email) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        user.setEmail(email);
        return userRepository.save(user);
    }

    public User updateName(String userId, String name) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        user.setName(name);
        return userRepository.save(user);
    }

    public User updateBirth(String userId, String birth) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        user.setBirth(birth);
        return userRepository.save(user);
    }

    public User updateMajor(String userId, String major) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        user.setMajor(major);
        return userRepository.save(user);
    }

    public User updateCollege(String userId, String college) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        user.setCollege(college);
        return userRepository.save(user);
    }

    public boolean verifyPassword(String userId, String currentPassword) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        return passwordEncoder.matches(currentPassword, user.getPasswordHash());
    }

    public void updatePassword(String userId, String currentPassword, String newPassword) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid password");
        }
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    public void updatePasswordWithoutVerification(String userId, String newPassword) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    // 프로필 이미지 파일 업로드 및 업데이트
    @Transactional
    public User updateProfileImageWithFile(String userId, MultipartFile imageFile) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        
        if (imageFile == null || imageFile.isEmpty()) {
            throw new IllegalArgumentException("이미지 파일이 필요합니다.");
        }
        
        // 이미지 파일 검증
        String contentType = imageFile.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("이미지 파일만 업로드 가능합니다.");
        }
        
        try {
            // 업로드 디렉토리 생성
            Path uploadPath = Paths.get(PROFILE_IMAGE_UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            // 간단한 파일명 생성
            String originalFilename = imageFile.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            
            // 간단한 랜덤 문자열 생성 (6자리)
            String randomStr = generateRandomString(6);
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmm"));
            String finalFilename = timestamp + "_" + randomStr + fileExtension;
            
            // 파일 저장
            Path filePath = uploadPath.resolve(finalFilename);
            Files.copy(imageFile.getInputStream(), filePath);
            
            // User의 profileImage 업데이트 (웹에서 접근 가능한 URL)
            String imageUrl = PROFILE_IMAGE_URL_PREFIX + finalFilename;
            user.setProfileImage(imageUrl);
            
            return userRepository.save(user);
            
        } catch (IOException e) {
            throw new RuntimeException("프로필 이미지 파일 저장 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
    }

    // 간단한 랜덤 문자열 생성 메서드
    private String generateRandomString(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            int index = (int) (Math.random() * chars.length());
            sb.append(chars.charAt(index));
        }
        return sb.toString();
    }

    // 기존 메서드 (URL 방식) - 하위 호환성을 위해 유지
    public void updateProfileImage(String userId, String imagePath) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        user.setProfileImage(imagePath);
        userRepository.save(user);
    }

    public void addCoins(Long userId, int amount) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setCoinBalance(user.getCoinBalance() + amount);
        userRepository.save(user);
    }

    public User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("사용자를 찾을 수 없습니다."));
    }

    public User findByUserId(String userId) {
        return userRepository.findByUserId(userId)
                .orElseThrow(() -> new NoSuchElementException("사용자를 찾을 수 없습니다."));
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new NoSuchElementException("사용자를 찾을 수 없습니다."));
    }
}