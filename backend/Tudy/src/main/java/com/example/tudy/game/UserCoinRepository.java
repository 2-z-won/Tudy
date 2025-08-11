package com.example.tudy.game;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserCoinRepository extends JpaRepository<UserCoin, Long> {
    
    List<UserCoin> findByUser(User user);
    
    Optional<UserCoin> findByUserAndCoinType(User user, CoinType coinType);
    
    boolean existsByUserAndCoinType(User user, CoinType coinType);
}
