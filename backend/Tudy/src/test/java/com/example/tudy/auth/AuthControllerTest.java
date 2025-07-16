package com.example.tudy.auth;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void sendEmail_ValidPusanEmail_Success() throws Exception {
        String email = "your_test@pusan.ac.kr"; // 실제 테스트용 부산대 이메일로 변경
        mockMvc.perform(post("/api/auth/send-email")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\":\"" + email + "\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    @Test
    void sendEmail_InvalidEmail_Fail() throws Exception {
        mockMvc.perform(post("/api/auth/send-email")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\":\"test@gmail.com\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(false));
    }
} 