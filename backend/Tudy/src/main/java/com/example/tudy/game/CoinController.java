package com.example.tudy.game;

import com.example.tudy.user.User;
import com.example.tudy.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/coins")
@RequiredArgsConstructor
public class CoinController {
    
    private final CoinService coinService;
    private final UserService userService;
    
    /**
     * 사용자의 모든 코인 조회
     */
    @GetMapping
    public ResponseEntity<List<UserCoin>> getUserCoins(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증이 필요합니다.");
        }
        User user = userService.getUserByEmail(authentication.getName());
        List<UserCoin> coins = coinService.getUserCoins(user);
        return ResponseEntity.ok(coins);
    }
    
    /**
     * 사용자의 특정 타입 코인 조회
     */
    @GetMapping("/{coinType}")
    public ResponseEntity<UserCoin> getUserCoinByType(
            @PathVariable CoinType coinType,
            Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증이 필요합니다.");
        }
        User user = userService.getUserByEmail(authentication.getName());
        UserCoin coin = coinService.getUserCoinByType(user, coinType);
        return ResponseEntity.ok(coin);
    }
    
    /**
     * 사용자의 총 코인 수량 조회
     */
    @GetMapping("/total")
    public ResponseEntity<TotalCoinResponse> getTotalCoins(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "인증이 필요합니다.");
        }
        User user = userService.getUserByEmail(authentication.getName());
        int totalCoins = user.getCoinBalance();
        
        TotalCoinResponse response = new TotalCoinResponse();
        response.setTotalCoins(totalCoins);
        response.setUserId(user.getUserId());
        response.setUserName(user.getName());
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 총 코인 수량 응답 DTO
     */
    public static class TotalCoinResponse {
        private int totalCoins;
        private String userId;
        private String userName;
        
        // Getters and Setters
        public int getTotalCoins() { return totalCoins; }
        public void setTotalCoins(int totalCoins) { this.totalCoins = totalCoins; }
        
        public String getUserId() { return userId; }
        public void setUserId(String userId) { this.userId = userId; }
        
        public String getUserName() { return userName; }
        public void setUserName(String userName) { this.userName = userName; }
    }
}
