package com.example.tudy.game;

import com.example.tudy.user.User;
import com.example.tudy.user.UserService;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.NoSuchElementException;

@RestController
@RequestMapping("/api/coins")
@RequiredArgsConstructor
public class CoinController {

    private final CoinService coinService;
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

    /**
     * 사용자의 모든 코인 조회 (코인 타입별 amount만 반환)
     */
    @GetMapping
    public ResponseEntity<CoinSummaryResponse> getUserCoins(Authentication authentication) {
        User user = requireUser(authentication);
        List<UserCoin> coins = coinService.getUserCoins(user);
        
        CoinSummaryResponse response = new CoinSummaryResponse();
        for (UserCoin coin : coins) {
            switch (coin.getCoinType()) {
                case ACADEMIC_SAEDO:
                    response.setAcademicSaedo(coin.getAmount());
                    break;
                case GYM:
                    response.setGym(coin.getAmount());
                    break;
                case CAFE:
                    response.setCafe(coin.getAmount());
                    break;
            }
        }
        
        return ResponseEntity.ok(response);
    }

    /**
     * 사용자의 특정 타입 코인 조회 (amount만 반환)
     */
    @GetMapping("/{coinType}")
    public ResponseEntity<Integer> getUserCoinByType(
            @PathVariable String coinType,
            Authentication authentication
    ) {
        User user = requireUser(authentication);

        CoinType type;
        try {
            type = CoinType.valueOf(coinType);
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "잘못된 코인 타입입니다.");
        }

        int balance = coinService.getUserCoinBalanceByType(user, type);
        return ResponseEntity.ok(balance);
    }

    /**
     * 코인 타입별 간단한 요약 응답 DTO
     */
    public static class CoinSummaryResponse {
        @JsonProperty("ACADEMIC_SAEDO")
        private int academicSaedo = 0;
        
        @JsonProperty("GYM")
        private int gym = 0;
        
        @JsonProperty("CAFE")
        private int cafe = 0;

        public int getAcademicSaedo() {
            return academicSaedo;
        }

        public void setAcademicSaedo(int academicSaedo) {
            this.academicSaedo = academicSaedo;
        }

        public int getGym() {
            return gym;
        }

        public void setGym(int gym) {
            this.gym = gym;
        }

        public int getCafe() {
            return cafe;
        }

        public void setCafe(int cafe) {
            this.cafe = cafe;
        }
    }



    /**
     * 사용자의 총 코인 수량 조회
     */
    @GetMapping("/total")
    public ResponseEntity<TotalCoinResponse> getTotalCoins(Authentication authentication) {
        User user = requireUser(authentication);

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
