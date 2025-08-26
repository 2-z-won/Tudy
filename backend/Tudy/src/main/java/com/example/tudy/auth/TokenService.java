package com.example.tudy.auth;

import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class TokenService {
    private final Map<String, Long> tokens = new ConcurrentHashMap<>();
    private final Set<String> blacklist = ConcurrentHashMap.newKeySet();

    public String generateToken(Long userId) {
        String token = UUID.randomUUID().toString();
        tokens.put(token, userId);
        return token;
    }

    /**
     * 토큰 문자열을 이용해 사용자 ID 를 해석한다.
     * 잘못된 토큰이거나 블랙리스트에 등록된 토큰인 경우 null 을 반환한다.
     *
     * @param token UUID 기반 토큰 문자열
     * @return 토큰에 매핑된 사용자 ID, 없으면 null
     */
    public Long resolveUserId(String token) {
        if (token == null || blacklist.contains(token)) {
            return null;
        }
        return tokens.get(token);
    }

    public void blacklist(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return;
        }
        String token = authHeader.substring(7);
        blacklist.add(token);
    }
}
