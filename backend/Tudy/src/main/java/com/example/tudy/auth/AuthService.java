package com.example.tudy.auth;

import com.example.tudy.user.User;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AuthService {
    private final Map<String, Long> tokens = new ConcurrentHashMap<>();
    private final Set<String> blacklist = ConcurrentHashMap.newKeySet();

    public String generateToken(User user) {
        String token = UUID.randomUUID().toString();
        tokens.put(token, user.getId());
        return token;
    }

    public Long verify(String header) {
        if (header == null || !header.startsWith("Bearer ")) {
            throw new RuntimeException("Unauthorized");
        }
        String token = header.substring(7);
        if (blacklist.contains(token)) {
            throw new RuntimeException("Unauthorized");
        }
        Long id = tokens.get(token);
        if (id == null) {
            throw new RuntimeException("Unauthorized");
        }
        return id;
    }

    public void logout(String header) {
        if (header == null || !header.startsWith("Bearer ")) {
            return;
        }
        String token = header.substring(7);
        blacklist.add(token);
        tokens.remove(token);
    }
}
