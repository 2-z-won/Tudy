package com.example.tudy.category;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    boolean existsByName(String name);
    boolean existsByUserAndName(User user, String name);
    Category findByUserAndName(User user, String name);
    java.util.List<Category> findByUser(com.example.tudy.user.User user);
} 