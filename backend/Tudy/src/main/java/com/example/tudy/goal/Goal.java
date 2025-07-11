package com.example.tudy.goal;

import com.example.tudy.user.User;
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
    private User user;

    private String title;
    private String category;
    private LocalDate startDate;
    private LocalDate endDate;
    private boolean completed = false;
    private String proofImage;
    private Boolean isGroupGoal = false;
    private Long groupId;
}