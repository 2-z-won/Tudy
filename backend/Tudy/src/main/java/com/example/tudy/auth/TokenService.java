package com.example.tudy.auth;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class TokenService {

    @Value("${jwt.secret}")
    private String secret;

    private Key key;

    private final Set<String> blacklist = ConcurrentHashMap.newKeySet();

    @PostConstruct
    void init() {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String generateToken(Long userId) {
        return Jwts.builder()
                .setSubject(String.valueOf(userId))
                .signWith(key)
                .compact();
    }

    /**
     * JWT 토큰 문자열을 이용해 사용자 ID 를 해석한다.
     * 잘못된 토큰이거나 블랙리스트에 등록된 토큰인 경우 null 을 반환한다.
     *
     * @param token JWT 토큰 문자열
     * @return 토큰에 포함된 사용자 ID, 없으면 null
     */
    public Long resolveUserId(String token) {
        if (token == null || blacklist.contains(token)) {
            return null;
        }
        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
            return Long.parseLong(claims.getSubject());
        } catch (Exception e) {
            return null;
        }
    }

    public void blacklist(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return;
        }
        String token = authHeader.substring(7);
        blacklist.add(token);
    }
}

