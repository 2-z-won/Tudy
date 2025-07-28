package com.example.tudy.category;

import com.example.tudy.user.User;
import com.example.tudy.user.UserRepository;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
@Tag(name = "Category", description = "Category APIs")
public class CategoryController {
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;

    @PostMapping
    @Operation(summary = "Create category")
    @ApiResponse(responseCode = "200", description = "Category created")
    public ResponseEntity<?> create(@RequestBody CategoryRequest req) {
        User user = userRepository.findByUserId(req.getUserId()).orElseThrow();
        if (categoryRepository.existsByUserAndName(user, req.getName())) {
            return ResponseEntity.badRequest().body("이미 존재하는 카테고리명입니다.");
        }
        if (req.getColor() == null || req.getColor() < 1 || req.getColor() > 10) {
            return ResponseEntity.badRequest().body("색상은 1~10 사이여야 합니다.");
        }
        Category category = new Category();
        category.setName(req.getName());
        category.setColor(req.getColor());
        category.setCategoryType(req.getCategoryType());
        category.setUser(user);
        return ResponseEntity.ok(categoryRepository.save(category));
    }

    @GetMapping("/exists")
    @Operation(summary = "Check category name")
    @ApiResponse(responseCode = "200", description = "Check completed")
    public ResponseEntity<Boolean> existsByName(@RequestParam String userId, @RequestParam String name) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        return ResponseEntity.ok(categoryRepository.existsByUserAndName(user, name));
    }

    @GetMapping
    @Operation(summary = "List categories")
    @ApiResponse(responseCode = "200", description = "Categories listed")
    public ResponseEntity<List<CategoryResponse>> list(@RequestParam String userId) {
        User user = userRepository.findByUserId(userId).orElseThrow();
        List<Category> categories = categoryRepository.findByUser(user);
        List<CategoryResponse> result = categories.stream()
            .map(c -> new CategoryResponse(c.getId(), c.getName(), c.getColor(), c.getCategoryType()))
            .toList();
        return ResponseEntity.ok(result);
    }

    @Data
    private static class CategoryRequest {
        @Schema(description = "User ID", example = "1")
        private String userId;
        @Schema(description = "Category name", example = "공부")
        private String name;
        @Schema(description = "Color code", example = "1")
        private Integer color;
        @Schema(description = "Category type", example = "STUDY")
        private Category.CategoryType categoryType;
    }

    @Data
    class CategoryResponse {
        @Schema(description = "Category ID", example = "1")
        private Long id;
        @Schema(description = "Category name", example = "공부")
        private String name;
        @Schema(description = "Color code", example = "1")
        private Integer color;
        @Schema(description = "Category type", example = "STUDY")
        private Category.CategoryType categoryType;

        public CategoryResponse(Long id, String name, Integer color, Category.CategoryType categoryType) {
            this.id = id;
            this.name = name;
            this.color = color;
            this.categoryType = categoryType;
        }
    }
}

