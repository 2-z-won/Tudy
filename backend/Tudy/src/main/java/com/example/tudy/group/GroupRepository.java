package com.example.tudy.group;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface GroupRepository extends JpaRepository<Group, Long> {
    Page<Group> findByPasswordIsNull(Pageable pageable);
    Page<Group> findByPassword(String password, Pageable pageable);
}