package com.example.tudy.user;

import com.example.tudy.college.College;
import com.example.tudy.college.CollegeRepository;
import com.example.tudy.college.Department;
import com.example.tudy.college.DepartmentRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class UserCollegeControllerTests {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private UserService userService;
    @Autowired
    private CollegeRepository collegeRepository;
    @Autowired
    private DepartmentRepository departmentRepository;

    @Test
    void changeCollege() throws Exception {
        College c = new College();
        c.setName("Engineering");
        c.setCode("EN2");
        collegeRepository.save(c);
        Department d = new Department();
        d.setName("CS");
        d.setCode("CS2");
        d.setCollege(c);
        departmentRepository.save(d);

        User user = userService.signUp("cc@test.com", "pwd", "nick", "M");

        String json = "{\"collegeId\": " + c.getId() + ", \"departmentId\": " + d.getId() + "}";
        mockMvc.perform(put("/api/users/" + user.getId() + "/college")
                .contentType(MediaType.APPLICATION_JSON)
                .header("X-USER-ID", String.valueOf(user.getId()))
                .content(json))
                .andExpect(status().isOk());
    }
}
