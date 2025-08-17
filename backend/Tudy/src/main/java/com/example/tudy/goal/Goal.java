package com.example.tudy.goal;

import com.example.tudy.user.User;
import com.example.tudy.category.Category;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@Entity
@Table(name = "goals")
public class Goal {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private User user;

    private String title;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Category category;
    private LocalDate startDate;
    private LocalDate endDate;
    private boolean completed = false;
    private String proofImage;
    private Boolean isGroupGoal = false;
    private Long groupId;
    private Boolean isFriendGoal = false;
    private String friendName;
    @Enumerated(EnumType.STRING)
    private ProofType proofType;
    private Integer targetTime; // 목표 시간(초)
    private long totalDuration;

    public enum ProofType {
        TIME, IMAGE
    }
}