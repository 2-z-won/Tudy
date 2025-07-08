package com.example.tudy.group;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
class GroupServiceTests {

    @Autowired
    private GroupService groupService;
    @Autowired
    private GroupRepository groupRepository;

    @Test
    void createUpdateDeleteAndList() {
        Group g = groupService.createGroup("g1", false, null);
        assertThat(g.getId()).isNotNull();

        groupService.updateGroup(g.getId(), "g2", true, "pwd");
        Group updated = groupRepository.findById(g.getId()).orElseThrow();
        assertThat(updated.getName()).isEqualTo("g2");
        assertThat(updated.isPrivate()).isTrue();

        List<Group> publics = groupService.listGroups(true, null);
        assertThat(publics).isEmpty();

        List<Group> privates = groupService.listGroups(false, "pwd");
        assertThat(privates).hasSize(1);

        groupService.deleteGroup(g.getId());
        assertThat(groupRepository.findById(g.getId())).isEmpty();
    }
}
