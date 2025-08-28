package com.example.tudy.study;

import com.example.tudy.goal.Goal;
import com.example.tudy.goal.GoalRepository;
import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class StudySessionRankingTests {
    @Autowired MockMvc mockMvc;
    @Autowired UserRepository userRepository;
    @Autowired GoalRepository goalRepository;
    @Autowired StudySessionRepository studySessionRepository;

    @Test
    @DisplayName("Ranking by major returns 200 even when a user has null major")
    void rankingHandlesNullMajor() throws Exception {
        User user = userRepository.save(
                new User(null, "nullmajor@tudy.com", "nullmajor", "pw", "name", "2000.01.01", null, "college", null, 0)
        );
        Goal goal = new Goal();
        goal.setUser(user);
        goal.setTitle("goal");
        goalRepository.save(goal);

        StudySession session = new StudySession();
        session.setUser(user);
        session.setGoal(goal);
        session.setDuration(60);
        session.setCreatedAt(LocalDateTime.now());
        studySessionRepository.save(session);

        mockMvc.perform(get("/api/sessions/ranking")
                .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rankings").isArray());
    }
}
