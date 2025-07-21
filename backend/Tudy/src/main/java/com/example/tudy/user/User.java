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

    @Column(nullable = false, unique = true)
    private String userId; // 로그인용 아이디

    @Column(nullable = false)
    private String passwordHash;

    @Column(nullable = false, unique = true)
    private String name; // 이름 or 닉네임

    private String birth; // yyyy.mm.dd

    private String major;

    private String college;

    private String profileImage;

    private Integer coinBalance = 0;

    public User(Long id, String email, String userId, String passwordHash, String name, String birth, String major, String college, String profileImage, Integer coinBalance) {
        this.id = id;
        this.email = email;
        this.userId = userId;
        this.passwordHash = passwordHash;
        this.name = name;
        this.birth = birth;
        this.major = major;
        this.college = college;
        this.profileImage = profileImage;
        this.coinBalance = coinBalance;
    }
}