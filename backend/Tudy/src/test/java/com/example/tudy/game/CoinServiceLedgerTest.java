package com.example.tudy.game;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
@Transactional
class CoinServiceLedgerTest {

    @Autowired
    private CoinService coinService;

    @Autowired
    private UserCoinRepository userCoinRepository;

    @Autowired
    private UserRepository userRepository;

    @Test
    void getUserCoinBalanceByType_sumsLedgerEntries() {
        User user = new User();
        user.setEmail("ledger@test.com");
        user.setUserId("ledgeruser");
        user.setPasswordHash("password");
        user.setName("Ledger User");
        userRepository.save(user);

        UserCoin first = new UserCoin(user, CoinType.CAFE);
        first.setAmount(30);
        userCoinRepository.save(first);

        UserCoin second = new UserCoin(user, CoinType.CAFE);
        second.setAmount(20);
        userCoinRepository.save(second);

        int balance = coinService.getUserCoinBalanceByType(user, CoinType.CAFE);
        assertEquals(50, balance);
    }
}

