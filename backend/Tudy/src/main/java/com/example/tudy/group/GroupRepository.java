package com.example.tudy.group;

import org.springframework.data.jpa.repository.JpaRepository;

public interface GroupRepository extends JpaRepository<Group, Long> {
    // 그룹명으로 존재 여부 확인
    boolean existsByName(String name);
    
    // 그룹명으로 그룹 조회
    Group findByName(String name);
}