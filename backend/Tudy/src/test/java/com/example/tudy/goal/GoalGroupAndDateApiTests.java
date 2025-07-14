package com.example.tudy.goal;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import com.example.tudy.group.Group;
import com.example.tudy.group.GroupRepository;
import com.example.tudy.group.GroupMemberRepository;
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
public class GoalGroupAndDateApiTests {
    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;
    @Autowired UserRepository userRepository;
    @Autowired GroupRepository groupRepository;
    @Autowired GroupMemberRepository groupMemberRepository;

    @Test
    @DisplayName("그룹 목표 생성 시 그룹원별 카테고리 자동 생성 및 목표 생성")
    void createGroupGoalAndCheckMemberGoals() throws Exception {
        // 그룹장, 그룹원 생성
        User leader = userRepository.save(new User(null, "leader@tudy.com", "pw", "리더", null, null, 0));
        User member = userRepository.save(new User(null, "member@tudy.com", "pw", "멤버", null, null, 0));
        Group group = new Group();
        group.setName("테스트그룹");
        group.setPassword("123456");
        group = groupRepository.save(group);
        groupMemberRepository.save(new com.example.tudy.group.GroupMember(leader, group));
        groupMemberRepository.save(new com.example.tudy.group.GroupMember(member, group));
        String categoryName = "그룹카테고리";
        String title = "그룹 목표";
        String startDate = LocalDate.now().toString();
        String endDate = LocalDate.now().plusDays(3).toString();
        // 그룹 목표 생성 (리더가 생성)
        String reqJson = "{" +
                "\"userId\":" + leader.getId() + "," +
                "\"title\":\"" + title + "\"," +
                "\"categoryName\":\"" + categoryName + "\"," +
                "\"startDate\":\"" + startDate + "\"," +
                "\"endDate\":\"" + endDate + "\"," +
                "\"isGroupGoal\":true," +
                "\"groupId\":" + group.getId() +
                "}";
        mockMvc.perform(post("/api/goals")
                .contentType(MediaType.APPLICATION_JSON)
                .content(reqJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value(title));
        // 그룹원(멤버)도 같은 카테고리명으로 목표가 생성되어야 함
        mockMvc.perform(get("/api/goals")
                .param("userId", member.getId().toString())
                .param("categoryName", categoryName))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value(title));
    }

    @Test
    @DisplayName("날짜별+카테고리명으로 목표 조회")
    void listGoalsByDateAndCategoryName() throws Exception {
        User user = userRepository.save(new User(null, "dategoal@tudy.com", "pw", "날짜테스터", null, null, 0));
        String categoryName = "날짜카테고리";
        String title = "날짜별 목표";
        String startDate = LocalDate.now().toString();
        String endDate = LocalDate.now().plusDays(2).toString();
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
        // 날짜별+카테고리명으로 조회
        mockMvc.perform(get("/api/goals/by-date")
                .param("userId", user.getId().toString())
                .param("date", startDate)
                .param("categoryName", categoryName))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value(title));
    }
} 