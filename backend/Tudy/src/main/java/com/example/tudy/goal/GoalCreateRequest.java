package com.example.tudy.goal;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class GoalCreateRequest {
    @Schema(description = "User ID", example = "user1")
    @NotBlank
    private String userId;

    @Schema(description = "Goal title", example = "스터디 목표")
    @NotBlank
    private String title;

    @Schema(description = "Category name", example = "공부")
    @NotBlank
    private String categoryName;

    @Schema(description = "Start date", example = "2024-01-01")
    @JsonFormat(pattern = "yyyy-MM-dd")
    @NotNull
    private LocalDate startDate;

    @Schema(description = "End date", example = "2024-01-31")
    @JsonFormat(pattern = "yyyy-MM-dd")
    @NotNull
    private LocalDate endDate;

    @Schema(description = "Group goal flag", example = "false")
    @NotNull
    @JsonProperty("isGroupGoal")
    private Boolean isGroupGoal;

    @Schema(description = "Group ID", example = "1")
    private Long groupId;

    @Schema(description = "Friend goal flag", example = "false")
    @NotNull
    @JsonProperty("isFriendGoal")
    private Boolean isFriendGoal;

    @Schema(description = "Friend name", example = "친구")
    private String friendName;

    @Schema(description = "Proof type", example = "TIME")
    @NotNull
    private Goal.ProofType proofType;

    @Schema(description = "Target time in seconds", example = "7200")
    private Integer targetTime;
}
