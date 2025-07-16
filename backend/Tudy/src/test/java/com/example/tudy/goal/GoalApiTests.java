package com.example.tudy.goal;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import com.example.tudy.study.StudySession;
import com.example.tudy.study.StudySessionRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class GoalApiTests {
    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;
    @Autowired UserRepository userRepository;
    @Autowired StudySessionRepository studySessionRepository;

    @Test
    @DisplayName("목표 생성 및 카테고리명으로 조회")
    void createAndListGoalByCategoryName() throws Exception {
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
        String categoryName = "운동";
        String title = "아침 운동";
        String startDate = LocalDate.now().toString();
        String endDate = LocalDate.now().plusDays(7).toString();
        // 목표 생성
        String reqJson = "{" +
                "\"userId\":" + user.getId() + "," +
                "\"title\":\"" + title + "\"," +
                "\"categoryName\":\"" + categoryName + "\"," +
                "\"startDate\":\"" + startDate + "\"," +
                "\"endDate\":\"" + endDate + "\"," +
                "\"isGroupGoal\":false," +
                "\"groupId\":null" +
                "}";
        mockMvc.perform(post("/api/goals")
                .contentType(MediaType.APPLICATION_JSON)
                .content(reqJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value(title));
        // 카테고리명으로 조회
        mockMvc.perform(get("/api/goals")
                .param("userId", user.getId().toString())
                .param("categoryName", categoryName))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value(title));
    }

    @Test
    @DisplayName("사진 인증으로 목표 완료")
    void completeWithProofImage() throws Exception {
        User user = userRepository.save(new User(null, "proof@tudy.com", "proofuser", "pw",
                "사진테스터", "2000.01.01", "컴퓨터공학", "공과대학", null, 0));

        String reqJson = "{" +
                "\"userId\":" + user.getId() + "," +
                "\"title\":\"title\"," +
                "\"categoryName\":\"cat\"," +
                "\"startDate\":\"" + LocalDate.now() + "\"," +
                "\"endDate\":\"" + LocalDate.now().plusDays(1) + "\"," +
                "\"isGroupGoal\":false," +
                "\"groupId\":null" +
                "}";

        String res = mockMvc.perform(post("/api/goals")
                .contentType(MediaType.APPLICATION_JSON)
                .content(reqJson))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        Goal goal = objectMapper.readValue(res, Goal.class);

        mockMvc.perform(post("/api/goals/" + goal.getId() + "/complete")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"proofImage\":\"img.png\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.completed").value(true));
    }

    @Test
    @DisplayName("2시간 공부 후 목표 완료")
    void completeWithStudyTime() throws Exception {
        User user = userRepository.save(new User(null, "time@tudy.com", "timeuser", "pw",
                "시간테스터", "2000.01.01", "컴퓨터공학", "공과대학", null, 0));

        String reqJson = "{" +
                "\"userId\":" + user.getId() + "," +
                "\"title\":\"title\"," +
                "\"categoryName\":\"cat\"," +
                "\"startDate\":\"" + LocalDate.now() + "\"," +
                "\"endDate\":\"" + LocalDate.now().plusDays(1) + "\"," +
                "\"isGroupGoal\":false," +
                "\"groupId\":null" +
                "}";

        String res = mockMvc.perform(post("/api/goals")
                .contentType(MediaType.APPLICATION_JSON)
                .content(reqJson))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        Goal goal = objectMapper.readValue(res, Goal.class);

        StudySession session = new StudySession();
        session.setUser(user);
        session.setGoal(goal);
        session.setStartTime(java.time.LocalDateTime.now());
        session.setEndTime(java.time.LocalDateTime.now());
        session.setDuration(7200);
        studySessionRepository.save(session);

        mockMvc.perform(post("/api/goals/" + goal.getId() + "/complete"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.completed").value(true));
    }
}