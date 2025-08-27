package com.example.tudy.auth;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(properties = {
        "spring.datasource.url=jdbc:h2:mem:testdb",
        "spring.datasource.driverClassName=org.h2.Driver",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "jwt.secret=testtesttesttesttesttesttesttest",
        "jwt.expiration=3600000"
})
class TokenServiceTest {

    @Autowired
    TokenService tokenService;

    @Test
    void generatedTokenContainsThreePartsAndResolvesUserId() {
        String token = tokenService.generateToken(42L);
        assertThat(token.split("\\.")).hasSize(3);
        Long userId = tokenService.resolveUserId(token);
        assertThat(userId).isEqualTo(42L);
    }
}
