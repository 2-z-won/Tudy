package com.example.tudy.category;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class CategoryApiTests {
    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;
    @Autowired UserRepository userRepository;

    @Test
    @DisplayName("카테고리 생성 및 중복 체크")
    void createAndCheckCategory() throws Exception {
        User user = userRepository.save(
                new User(
                        null, // id
                        "catapi@tudy.com", // email
                        "catapiuser",      // userId (로그인용 아이디)
                        "pw",              // passwordHash
                        "카테고리테스터",   // name
                        "2000.01.01",      // birth
                        "컴퓨터공학",       // major
                        "공과대학",        // college
                        null,              // profileImage
                        0                  // coinBalance
                )
        );
        String name = "공부";
        int color = 2;
        // 카테고리 생성
        String reqJson = "{" +
                "\"userId\":" + user.getId() + "," +
                "\"name\":\"" + name + "\"," +
                "\"color\":2" +
                "}";
        mockMvc.perform(post("/api/categories")
                .contentType(MediaType.APPLICATION_JSON)
                .content(reqJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value(name));
        // 중복 체크
        mockMvc.perform(get("/api/categories/exists")
                .param("userId", user.getId().toString())
                .param("name", name))
                .andExpect(status().isOk())
                .andExpect(content().string("true"));
        // 전체 목록
        mockMvc.perform(get("/api/categories")
                .param("userId", user.getId().toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name").value(name));
    }
} 