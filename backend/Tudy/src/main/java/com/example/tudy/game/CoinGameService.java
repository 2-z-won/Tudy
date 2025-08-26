package com.example.tudy.game;

import com.example.tudy.user.User;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Random;

@Service
@RequiredArgsConstructor
@Transactional
public class CoinGameService {

    private final CoinService coinService;
    private final CoinGameAttemptRepository attemptRepository;
    private final Random random = new Random();

    public CoinGameResult playGame(User user, int betAmount) {
        if (betAmount <= 0) {
            throw new IllegalArgumentException("베팅 금액은 0보다 커야 합니다.");
        }
        if (user.getCoinBalance() < betAmount) {
            throw new IllegalStateException("코인이 부족합니다.");
        }

        LocalDate today = LocalDate.now();
        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime endOfDay = today.plusDays(1).atStartOfDay().minusNanos(1);
        long attempts = attemptRepository.countByUserAndAttemptedAtBetween(user, startOfDay, endOfDay);
        if (attempts >= 3) {
            throw new IllegalStateException("하루 3번만 플레이할 수 있습니다.");
        }

        boolean success = random.nextBoolean();
        if (success) {
            coinService.addCoinsToUser(user, CoinType.ACADEMIC_SAEDO, betAmount);
        } else {
            coinService.subtractCoins(user, betAmount);
        }

        CoinGameAttempt attempt = new CoinGameAttempt();
        attempt.setUser(user);
        attempt.setAttemptedAt(LocalDateTime.now());
        attempt.setBetAmount(betAmount);
        attempt.setSuccess(success);
        attemptRepository.save(attempt);

        CoinGameResult result = new CoinGameResult();
        result.setSuccess(success);
        result.setCurrentBalance(user.getCoinBalance());
        return result;
    }

    @Getter
    @Setter
    public static class CoinGameResult {
        private boolean success;
        private int currentBalance;
    }
}
