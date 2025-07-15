package com.example.tudy.group;

import org.springframework.data.jpa.repository.JpaRepository;

public interface GroupRepository extends JpaRepository<Group, Long> {
    boolean existsByName(String name);

    org.springframework.data.domain.Page<Group> findByIsPrivateFalse(org.springframework.data.domain.Pageable pageable);

    org.springframework.data.domain.Page<Group> findByIsPrivateTrueAndPassword(String password, org.springframework.data.domain.Pageable pageable);
}