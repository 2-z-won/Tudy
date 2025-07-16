package com.example.tudy.user;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    private String nickname;

    private String major;

    private String college;

    private String profileImage;

    private Integer coinBalance = 0;

    public User(Long id, String email, String passwordHash, String nickname,
                String major, String profileImage, Integer coinBalance) {
        this.id = id;
        this.email = email;
        this.passwordHash = passwordHash;
        this.nickname = nickname;
        this.major = major;
        this.profileImage = profileImage;
        this.coinBalance = coinBalance;
    }
}