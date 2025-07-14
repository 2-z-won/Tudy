package com.example.tudy.integration;

import com.example.tudy.user.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class UserApiTests {

    @Autowired
    MockMvc mockMvc;
    @Autowired
    UserService userService;
    @Autowired
    ObjectMapper objectMapper;

    private String login(String email, String password) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/users/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\":\""+email+"\",\"password\":\""+password+"\"}"))
                .andExpect(status().isOk())
                .andReturn();
        return objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();
    }

    @Test
    void changeEmailSuccess() throws Exception {
        var u = userService.signUp("a@a.com","pw","n","CS");
        String token = login("a@a.com","pw");
        mockMvc.perform(put("/api/users/"+u.getId()+"/email")
                        .header("Authorization","Bearer "+token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"b@b.com\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("b@b.com"));
    }

    @Test
    void changeEmailForbidden() throws Exception {
        var u1 = userService.signUp("c@c.com","pw","n","CS");
        var u2 = userService.signUp("d@d.com","pw","n","CS");
        String token = login("d@d.com","pw");
        mockMvc.perform(put("/api/users/"+u1.getId()+"/email")
                        .header("Authorization","Bearer "+token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"x@x.com\"}"))
                .andExpect(status().isForbidden());
    }

    @Test
    void changeEmailConflict() throws Exception {
        var u1 = userService.signUp("e@e.com","pw","n","CS");
        userService.signUp("f@f.com","pw","n","CS");
        String token = login("e@e.com","pw");
        mockMvc.perform(put("/api/users/"+u1.getId()+"/email")
                        .header("Authorization","Bearer "+token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"f@f.com\"}"))
                .andExpect(status().isConflict());
    }
}
