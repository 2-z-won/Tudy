package com.example.tudy.user;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public User signUp(String email, String password, String nickname, String major) {
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("Email already exists");
        }
        User user = new User();
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setNickname(nickname);
        user.setMajor(major);
        user.setCoinBalance(0);
        return userRepository.save(user);
    }

    public Optional<User> login(String email, String password) {
        return userRepository.findByEmail(email)
                .filter(u -> passwordEncoder.matches(password, u.getPasswordHash()));
    }

    public boolean emailExists(String email) {
        return userRepository.findByEmail(email).isPresent();
    }

    public User updateEmail(Long userId, String email) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setEmail(email);
        return userRepository.save(user);
    }

    public User updateMajor(Long userId, String major) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setMajor(major);
        return userRepository.save(user);
    }

    public User updateCollege(Long userId, String college) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setCollege(college);
        return userRepository.save(user);
    }

    public void updateNickname(Long userId, String nickname) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setNickname(nickname);
        userRepository.save(user);
    }

    public void updatePassword(Long userId, String currentPassword, String newPassword) {
        User user = userRepository.findById(userId).orElseThrow();
        if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid password");
        }
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    public void updateProfileImage(Long userId, String imagePath) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setProfileImage(imagePath);
        userRepository.save(user);
    }

        public void addCoins(Long userId, int amount) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setCoinBalance(user.getCoinBalance() + amount);
        userRepository.save(user);
    }
}