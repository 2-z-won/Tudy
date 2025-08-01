package com.example.tudy.category;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    List<Category> findByUser(User user);
    boolean existsByUserAndName(User user, String name);
    java.util.Optional<Category> findByUserAndName(User user, String name);
}