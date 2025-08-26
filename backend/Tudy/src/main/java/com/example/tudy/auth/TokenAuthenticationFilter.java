package com.example.tudy.auth;

import com.example.tudy.user.User;
import com.example.tudy.user.UserService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.NoSuchElementException;

@Component
@RequiredArgsConstructor
public class TokenAuthenticationFilter extends OncePerRequestFilter {

    private final TokenService tokenService;
    private final UserService userService;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        Authentication currentAuth = SecurityContextHolder.getContext().getAuthentication();

        // 이미 인증되어 있거나(익명 포함) 유효한 Authentication이 존재하면 덮어쓰지 않음
        boolean hasAuth =
                currentAuth != null
                        && currentAuth.isAuthenticated()
                        && !"anonymousUser".equals(currentAuth.getPrincipal());

        if (!hasAuth) {
            String authHeader = request.getHeader("Authorization");
            Long userId = tokenService.resolveUserId(authHeader); // null 반환 가능 (토큰 없음/무효)
            if (userId != null) {
                try {
                    User user = userService.findById(userId);

                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(
                                    user.getEmail(), // principal
                                    null,            // credentials
                                    Collections.emptyList() // authorities
                            );
                    authentication.setDetails(
                            new WebAuthenticationDetailsSource().buildDetails(request)
                    );
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                } catch (NoSuchElementException ignored) {
                    // 유저가 없으면 컨텍스트를 건드리지 않고 그대로 둠(비인증 상태 유지)
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}
