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
        User user = userService.signUp("test@example.com", "secret", "tester", "CS");
        assertThat(user.getId()).isNotNull();
        assertThat(user.getPasswordHash()).isNotEqualTo("secret");

        assertThat(userRepository.findByEmail("test@example.com")).isPresent();
        assertThat(userService.login("test@example.com", "secret")).isPresent();
        assertThat(userService.login("test@example.com", "wrong")).isEmpty();
    }
}