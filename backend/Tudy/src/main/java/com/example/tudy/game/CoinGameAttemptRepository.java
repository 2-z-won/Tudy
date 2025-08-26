package com.example.tudy.game;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;

@Repository
public interface CoinGameAttemptRepository extends JpaRepository<CoinGameAttempt, Long> {
    long countByUserAndAttemptedAtBetween(User user, LocalDateTime start, LocalDateTime end);
}
