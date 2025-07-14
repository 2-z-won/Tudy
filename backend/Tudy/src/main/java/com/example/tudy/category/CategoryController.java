package com.example.tudy.category;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<?> create(@RequestBody CategoryRequest req) {
        User user = userRepository.findById(req.getUserId()).orElseThrow();
        if (categoryRepository.existsByUserAndName(user, req.getName())) {
            return ResponseEntity.badRequest().body("이미 존재하는 카테고리명입니다.");
        }
        if (req.getColor() == null || req.getColor() < 1 || req.getColor() > 10) {
            return ResponseEntity.badRequest().body("색상은 1~10 사이여야 합니다.");
        }
        Category category = new Category();
        category.setName(req.getName());
        category.setColor(req.getColor());
        category.setUser(user);
        return ResponseEntity.ok(categoryRepository.save(category));
    }

    @GetMapping("/exists")
    public ResponseEntity<Boolean> existsByName(@RequestParam Long userId, @RequestParam String name) {
        User user = userRepository.findById(userId).orElseThrow();
        return ResponseEntity.ok(categoryRepository.existsByUserAndName(user, name));
    }

    @GetMapping
    public ResponseEntity<List<Category>> list() {
        return ResponseEntity.ok(categoryRepository.findAll());
    }

    @Data
    private static class CategoryRequest {
        private Long userId;
        private String name;
        private Integer color;
    }
} 