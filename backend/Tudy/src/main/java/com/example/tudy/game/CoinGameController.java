package com.example.tudy.game;

import com.example.tudy.auth.TokenService;
import com.example.tudy.user.User;
import com.example.tudy.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.NoSuchElementException;

@RestController
@RequestMapping("/api/coins/game")
@RequiredArgsConstructor
public class CoinGameController {

    private final CoinGameService coinGameService;
    private final UserService userService;
    private final TokenService tokenService;

    // 공통 인증 유저 조회
    private User requireUser(String authHeader) {
        Long userId = tokenService.resolveUserId(authHeader);
        if (userId == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증이 필요합니다.");
        }

        try {
            return userService.findById(userId);
        } catch (NoSuchElementException e) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증정보가 유효하지 않습니다.");
        }
    }

    @PostMapping
    public ResponseEntity<CoinGameService.CoinGameResult> playGame(@RequestParam int bet,
                                                                  @RequestHeader(value = "Authorization", required = false) String authHeader) {
        User user = requireUser(authHeader);
        CoinGameService.CoinGameResult result = coinGameService.playGame(user, bet);
        return ResponseEntity.ok(result);
    }
}
