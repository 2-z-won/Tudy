package com.example.tudy.game;

import com.example.tudy.category.Category;
import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class CoinService {
    
    private final UserCoinRepository userCoinRepository;
    private final UserRepository userRepository;
    
    /**
     * 사용자의 모든 코인 정보 조회
     */
    public List<UserCoin> getUserCoins(User user) {
        return userCoinRepository.findByUser(user);
    }
    
    /**
     * 사용자의 특정 타입 코인 조회
     */
    public UserCoin getUserCoinByType(User user, CoinType coinType) {
        return userCoinRepository.findByUserAndCoinType(user, coinType)
                .orElseGet(() -> createInitialCoin(user, coinType));
    }
    
    /**
     * 목표 완료 시 카테고리 타입에 따른 코인 지급
     */
    public void awardCoinsForGoalCompletion(User user, Category.CategoryType categoryType) {
        CoinType coinType = getCoinTypeForCategory(categoryType);
        Integer coinAmount = getCoinAmountForCategory(categoryType);
        
        addCoinsToUser(user, coinType, coinAmount);
    }
    
    /**
     * 사용자로부터 코인 차감 (건물 시스템용)
     */
    public void subtractCoins(User user, Integer amount) {
        // 총 코인 수량 확인
        if (user.getCoinBalance() < amount) {
            throw new IllegalStateException("코인이 부족합니다. 필요: " + amount + ", 보유: " + user.getCoinBalance());
        }
        
        // 각 코인 타입에서 비례적으로 차감
        List<UserCoin> userCoins = getUserCoins(user);
        int totalCoins = userCoins.stream().mapToInt(UserCoin::getAmount).sum();
        
        for (UserCoin userCoin : userCoins) {
            if (userCoin.getAmount() > 0) {
                int subtractAmount = (int) Math.ceil((double) userCoin.getAmount() / totalCoins * amount);
                subtractAmount = Math.min(subtractAmount, userCoin.getAmount());
                
                userCoin.subtractAmount(subtractAmount);
                userCoinRepository.save(userCoin);
                
                amount -= subtractAmount;
                if (amount <= 0) break;
            }
        }
        
        // User의 coinBalance 업데이트
        updateUserTotalCoinBalance(user);
    }
    
    /**
     * 사용자에게 코인 추가
     */
    private void addCoinsToUser(User user, CoinType coinType, Integer amount) {
        UserCoin userCoin = userCoinRepository.findByUserAndCoinType(user, coinType)
                .orElseGet(() -> createInitialCoin(user, coinType));
        
        userCoin.addAmount(amount);
        userCoinRepository.save(userCoin);
        
        // User의 coinBalance도 업데이트 (모든 코인 종류의 합계)
        updateUserTotalCoinBalance(user);
    }
    
    /**
     * 사용자의 총 코인 수량 계산 및 업데이트
     */
    private void updateUserTotalCoinBalance(User user) {
        List<UserCoin> allCoins = userCoinRepository.findByUser(user);
        int totalBalance = allCoins.stream()
                .mapToInt(UserCoin::getAmount)
                .sum();
        
        user.setCoinBalance(totalBalance);
        userRepository.save(user);
    }
    
    /**
     * 카테고리 타입에 따른 코인 타입 결정
     */
    private CoinType getCoinTypeForCategory(Category.CategoryType categoryType) {
        return switch (categoryType) {
            case STUDY -> CoinType.ACADEMIC_SAEDO;
            case EXERCISE -> CoinType.GYM;
            case ETC -> CoinType.ACADEMIC_SAEDO;
        };
    }
    
    /**
     * 카테고리 타입에 따른 코인 수량 결정
     */
    private Integer getCoinAmountForCategory(Category.CategoryType categoryType) {
        return switch (categoryType) {
            case STUDY -> 50;
            case EXERCISE -> 50;
            case ETC -> 20;
        };
    }
    
    /**
     * 초기 코인 생성
     */
    private UserCoin createInitialCoin(User user, CoinType coinType) {
        UserCoin userCoin = new UserCoin(user, coinType);
        return userCoinRepository.save(userCoin);
    }
}
