package com.example.tudy.game;

import com.example.tudy.user.User;
import com.example.tudy.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/coins/game")
@RequiredArgsConstructor
public class CoinGameController {

    private final CoinGameService coinGameService;
    private final UserService userService;

    @PostMapping
    public ResponseEntity<CoinGameService.CoinGameResult> playGame(@RequestParam int bet, Authentication authentication) {
        if (authentication == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증이 필요합니다.");
        }
        String email = authentication.getName();
        if (email == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증정보가 유효하지 않습니다.");
        }
        User user = userService.getUserByEmail(email);
        CoinGameService.CoinGameResult result = coinGameService.playGame(user, bet);
        return ResponseEntity.ok(result);
    }
}
