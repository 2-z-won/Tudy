package com.example.tudy.user;

import com.example.tudy.game.CoinService;
import com.example.tudy.service.S3FileService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.Optional;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final CoinService coinService;
    private final S3FileService s3FileService;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

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

    // 프로필 이미지 파일 업로드 및 업데이트 (S3 사용)
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
            // 기존 프로필 이미지가 있다면 S3에서 삭제
            if (user.getProfileImage() != null && user.getProfileImage().contains("amazonaws.com")) {
                s3FileService.deleteFile(user.getProfileImage());
            }
            
            // S3에 파일 업로드
            String imageUrl = s3FileService.uploadFile(imageFile, "profile-images");
            
            // User의 profileImage 업데이트
            user.setProfileImage(imageUrl);
            
            return userRepository.save(user);
            
        } catch (Exception e) {
            throw new RuntimeException("프로필 이미지 파일 저장 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
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

    @Transactional
    public User cleanUser(String userId) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        coinService.subtractCoins(user, 50);
        user.setDirty(false);
        user.setLastStudyDate(LocalDate.now());
        return userRepository.save(user);
    }

    public User findById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("사용자를 찾을 수 없습니다."));
        updateDirtyStatus(user);
        return user;
    }

    public User findByUserId(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new NoSuchElementException("사용자를 찾을 수 없습니다."));
        updateDirtyStatus(user);
        return user;
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new NoSuchElementException("사용자를 찾을 수 없습니다."));
    }

    private void updateDirtyStatus(User user) {
        LocalDate last = user.getLastStudyDate();
        if (last != null && last.isBefore(LocalDate.now().minusDays(3))) {
            if (!user.isDirty()) {
                user.setDirty(true);
                userRepository.save(user);
            }
        }
    }
}