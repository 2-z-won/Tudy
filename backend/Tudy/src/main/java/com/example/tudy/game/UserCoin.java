package com.example.tudy.game;

import com.example.tudy.user.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "user_coins")
@Getter
@Setter
@NoArgsConstructor
public class UserCoin {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CoinType coinType;
    
    @Column(nullable = false)
    private Integer amount = 0;
    
    public UserCoin(User user, CoinType coinType) {
        this.user = user;
        this.coinType = coinType;
        this.amount = 0;
    }
    
    public void addAmount(Integer amount) {
        this.amount += amount;
    }
    
    public void subtractAmount(Integer amount) {
        if (this.amount >= amount) {
            this.amount -= amount;
        }
    }
}
