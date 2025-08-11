package com.example.tudy.group;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
public class GroupJoinRequestTests {

    @Autowired
    private GroupService groupService;

    @Autowired
    private GroupRepository groupRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private GroupJoinRequestRepository groupJoinRequestRepository;

    @Test
    public void testCreateGroupWithOwner() {
        // 사용자 생성
        User owner = new User();
        owner.setEmail("owner@test.com");
        owner.setUserId("owner");
        owner.setPasswordHash("password");
        owner.setName("Owner");
        userRepository.save(owner);

        // 그룹 생성
        Group group = groupService.createGroup("테스트 그룹", "123456", owner.getUserId());

        assertNotNull(group);
        assertEquals("테스트 그룹", group.getName());
        assertEquals(owner.getId(), group.getOwner().getId());
        assertEquals("123456", group.getPassword());
    }

    @Test
    public void testRequestJoinGroup() {
        // 사용자들 생성
        User owner = new User();
        owner.setEmail("owner@test.com");
        owner.setUserId("owner");
        owner.setPasswordHash("password");
        owner.setName("Owner");
        userRepository.save(owner);

        User applicant = new User();
        applicant.setEmail("applicant@test.com");
        applicant.setUserId("applicant");
        applicant.setPasswordHash("password");
        applicant.setName("Applicant");
        userRepository.save(applicant);

        // 그룹 생성
        Group group = groupService.createGroup("테스트 그룹", "123456", owner.getUserId());

        // 가입 신청
        String result = groupService.joinGroup(group.getId(), applicant.getUserId(), "123456");
        assertEquals("가입 신청이 완료되었습니다.", result);

        // 대기중인 신청 목록 확인
        var pendingRequests = groupService.getPendingRequests(group.getId(), owner.getUserId());
        assertEquals(1, pendingRequests.size());
        assertEquals(applicant.getId(), pendingRequests.get(0).getUser().getId());
    }

    @Test
    public void testApproveJoinRequest() {
        // 사용자들 생성
        User owner = new User();
        owner.setEmail("owner@test.com");
        owner.setUserId("owner");
        owner.setPasswordHash("password");
        owner.setName("Owner");
        userRepository.save(owner);

        User applicant = new User();
        applicant.setEmail("applicant@test.com");
        applicant.setUserId("applicant");
        applicant.setPasswordHash("password");
        applicant.setName("Applicant");
        userRepository.save(applicant);

        // 그룹 생성
        Group group = groupService.createGroup("테스트 그룹", "123456", owner.getUserId());

        // 가입 신청
        groupService.joinGroup(group.getId(), applicant.getUserId(), "123456");

        // 신청 승인
        var pendingRequests = groupService.getPendingRequests(group.getId(), owner.getUserId());
        Long requestId = pendingRequests.get(0).getId();

        String result = groupService.approveJoinRequest(requestId, owner.getUserId());
        assertEquals("가입 신청이 승인되었습니다.", result);

        // 승인 후 대기중인 신청이 없어야 함
        var remainingRequests = groupService.getPendingRequests(group.getId(), owner.getUserId());
        assertEquals(0, remainingRequests.size());
    }

    @Test
    public void testRejectJoinRequest() {
        // 사용자들 생성
        User owner = new User();
        owner.setEmail("owner@test.com");
        owner.setUserId("owner");
        owner.setPasswordHash("password");
        owner.setName("Owner");
        userRepository.save(owner);

        User applicant = new User();
        applicant.setEmail("applicant@test.com");
        applicant.setUserId("applicant");
        applicant.setPasswordHash("password");
        applicant.setName("Applicant");
        userRepository.save(applicant);

        // 그룹 생성
        Group group = groupService.createGroup("테스트 그룹", "123456", owner.getUserId());

        // 가입 신청
        groupService.joinGroup(group.getId(), applicant.getUserId(), "123456");

        // 신청 거부
        var pendingRequests = groupService.getPendingRequests(group.getId(), owner.getUserId());
        Long requestId = pendingRequests.get(0).getId();

        String result = groupService.rejectJoinRequest(requestId, owner.getUserId());
        assertEquals("가입 신청이 거부되었습니다.", result);

        // 거부 후 대기중인 신청이 없어야 함
        var remainingRequests = groupService.getPendingRequests(group.getId(), owner.getUserId());
        assertEquals(0, remainingRequests.size());
    }
} 