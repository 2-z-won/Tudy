package com.example.tudy.group;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GroupService {
    private final GroupRepository groupRepository;

    public Group createGroup(String name, boolean isPrivate, String password) {
        Group group = new Group();
        group.setName(name);
        group.setPrivate(isPrivate);
        group.setPassword(isPrivate ? password : null);
        return groupRepository.save(group);
    }

    public Group updateGroup(Long id, String name, boolean isPrivate, String password) {
        Group group = groupRepository.findById(id).orElseThrow();
        group.setName(name);
        group.setPrivate(isPrivate);
        group.setPassword(isPrivate ? password : null);
        return groupRepository.save(group);
    }

    public void deleteGroup(Long id) {
        groupRepository.deleteById(id);
    }

    public List<Group> listGroups(boolean isPublic, String password) {
        if (isPublic) {
            return groupRepository.findByIsPrivate(false);
        }
        return groupRepository.findByIsPrivate(true).stream()
                .filter(g -> g.getPassword() != null && g.getPassword().equals(password))
                .toList();
    }
}
