package com.example.tudy.game;

import com.example.tudy.user.User;
import com.example.tudy.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.NoSuchElementException;

@RestController
@RequestMapping("/api/coins/game")
@RequiredArgsConstructor
public class CoinGameController {

    private final CoinGameService coinGameService;
    private final UserService userService;

    // 공통 인증 유저 조회
    private User requireUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || authentication.getName() == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증이 필요합니다.");
        }

        try {
            return userService.getUserByEmail(authentication.getName());
        } catch (NoSuchElementException e) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증정보가 유효하지 않습니다.");
        }
    }

    @PostMapping
    public ResponseEntity<CoinGameService.CoinGameResult> playGame(@RequestParam int bet,
                                                                  Authentication authentication) {
        User user = requireUser(authentication);
        CoinGameService.CoinGameResult result = coinGameService.playGame(user, bet);
        return ResponseEntity.ok(result);
    }
}
