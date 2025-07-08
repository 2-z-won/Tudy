package com.example.tudy.user;

import com.example.tudy.college.College;
import com.example.tudy.college.CollegeRepository;
import com.example.tudy.college.Department;
import com.example.tudy.college.DepartmentRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
class UserCollegeTests {

    @Autowired
    private UserService userService;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private CollegeRepository collegeRepository;
    @Autowired
    private DepartmentRepository departmentRepository;

    @Test
    void updateCollegeAndDepartment() {
        College c = new College();
        c.setName("Engineering");
        c.setCode("ENG1");
        collegeRepository.save(c);

        Department d = new Department();
        d.setName("Computer");
        d.setCode("CS1");
        d.setCollege(c);
        departmentRepository.save(d);

        User user = userService.signUp("uc@test.com", "pwd", "nick", "CS");
        userService.updateCollege(user.getId(), c.getId(), d.getId());

        User updated = userRepository.findById(user.getId()).orElseThrow();
        assertThat(updated.getCollege().getId()).isEqualTo(c.getId());
        assertThat(updated.getDepartment().getId()).isEqualTo(d.getId());
    }
}
