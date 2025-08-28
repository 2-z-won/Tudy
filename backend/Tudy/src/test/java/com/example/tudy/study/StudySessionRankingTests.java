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
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class StudySessionRankingTests {

    @Autowired MockMvc mockMvc;
    @Autowired UserRepository userRepository;
    @Autowired GoalRepository goalRepository;
    @Autowired StudySessionRepository studySessionRepository;

    @Test
    @DisplayName("ranking endpoint handles users without majors")
    void rankingEndpointHandlesNullMajor() throws Exception {
        User noMajor = userRepository.save(new User(null, "n@tudy.com", "nomajor", "pw",
                "NoMajor", "2000.01.01", null, "college", null, 0));
        User withMajor = userRepository.save(new User(null, "y@tudy.com", "yesmajor", "pw",
                "YesMajor", "2000.01.01", "컴퓨터공학", "college", null, 0));

        Goal g1 = new Goal();
        g1.setUser(noMajor);
        g1.setTitle("g1");
        goalRepository.save(g1);

        Goal g2 = new Goal();
        g2.setUser(withMajor);
        g2.setTitle("g2");
        goalRepository.save(g2);

        StudySession s1 = new StudySession();
        s1.setUser(noMajor);
        s1.setGoal(g1);
        s1.setDuration(1800);
        s1.setCreatedAt(LocalDateTime.now());
        studySessionRepository.save(s1);

        StudySession s2 = new StudySession();
        s2.setUser(withMajor);
        s2.setGoal(g2);
        s2.setDuration(3600);
        s2.setCreatedAt(LocalDateTime.now());
        studySessionRepository.save(s2);

        mockMvc.perform(get("/api/sessions/ranking"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ranking", hasSize(2)))
                .andExpect(content().string(containsString("nomajor")));
    }
}

