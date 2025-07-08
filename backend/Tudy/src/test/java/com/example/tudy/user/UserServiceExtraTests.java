package com.example.tudy.user;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@Transactional
class UserServiceExtraTests {

    @Autowired
    private UserService userService;
    @Autowired
    private UserRepository userRepository;

    @Test
    void updateEmailAndMajor() {
        User user = userService.signUp("email1@test.com", "pwd", "nick", "CS");
        userService.updateEmail(user.getId(), "new@test.com");
        userService.updateMajor(user.getId(), "Math");

        User updated = userRepository.findById(user.getId()).orElseThrow();
        assertThat(updated.getEmail()).isEqualTo("new@test.com");
        assertThat(updated.getMajor()).isEqualTo("Math");
    }

    @Test
    void updateEmailWithDuplicate() {
        userService.signUp("one@test.com", "pwd", "n1", "CS");
        User user2 = userService.signUp("two@test.com", "pwd", "n2", "CS");

        assertThatThrownBy(() -> userService.updateEmail(user2.getId(), "one@test.com"))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void updateEmailWithInvalidFormat() {
        User user = userService.signUp("valid@test.com", "pwd", "nick", "CS");
        assertThatThrownBy(() -> userService.updateEmail(user.getId(), "bademail"))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
