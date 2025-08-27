package com.example.tudy.game;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.assertThrows;

@SpringBootTest
@Transactional
class CoinGameServiceTest {

    @Autowired
    private CoinGameService coinGameService;

    @Autowired
    private CoinService coinService;

    @Autowired
    private UserRepository userRepository;

    @Test
    void limitThreeAttemptsPerDay() {
        User user = new User();
        user.setEmail("game@test.com");
        user.setUserId("gameuser");
        user.setPasswordHash("password");
        user.setName("Game User");
        userRepository.save(user);

        coinService.addCoinsToUser(user, CoinType.ACADEMIC_SAEDO, 1000);

        for (int i = 0; i < 3; i++) {
            coinGameService.playGame(user, 10);
        }

        assertThrows(IllegalStateException.class, () -> coinGameService.playGame(user, 10));
    }
}
