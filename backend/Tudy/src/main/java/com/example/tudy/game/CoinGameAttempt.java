package com.example.tudy.game;

import com.example.tudy.user.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "coin_game_attempts")
@Getter
@Setter
@NoArgsConstructor
public class CoinGameAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false)
    private LocalDateTime attemptedAt;

    @Column(nullable = false)
    private Integer betAmount;

    @Column(nullable = false)
    private Boolean success;
}
