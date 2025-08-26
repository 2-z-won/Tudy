package com.example.tudy.building;

import com.example.tudy.building.BuildingController;
import com.example.tudy.building.BuildingService;
import com.example.tudy.user.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(BuildingController.class)
@AutoConfigureMockMvc(addFilters = false)
class BuildingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private BuildingService buildingService;

    @MockBean
    private UserService userService;

    @Test
    void getUserBuilding_withoutAuthentication_returnsUnauthorized() throws Exception {
        mockMvc.perform(get("/api/users/test/buildings/DEPARTMENT"))
                .andExpect(status().isUnauthorized());
    }
}
