package com.example.tudy.user;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
class UserServiceTests {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Test
    void signUpAndLogin() {
        User user = userService.signUp(
            "test@example.com", // email
            "testid",           // userId
            "secret",           // password
            "테스터",            // name
            "2000.01.01",       // birth
            "공과대학",          // college
            "CS"                // major
        );
        assertThat(user.getId()).isNotNull();
        assertThat(user.getPasswordHash()).isNotEqualTo("secret");

        assertThat(userRepository.findByEmail("test@example.com")).isPresent();
        assertThat(userService.login("testid", "secret")).isPresent();
        assertThat(userService.login("testid", "wrong")).isEmpty();
    }
}