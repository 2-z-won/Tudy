package com.example.tudy.game;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserCoinRepository extends JpaRepository<UserCoin, Long> {
    
    List<UserCoin> findByUser(User user);

    @Query("SELECT COALESCE(SUM(uc.amount), 0) FROM UserCoin uc WHERE uc.user = :user AND uc.coinType = :coinType")
    int sumAmountByUserAndCoinType(@Param("user") User user, @Param("coinType") CoinType coinType);
}
