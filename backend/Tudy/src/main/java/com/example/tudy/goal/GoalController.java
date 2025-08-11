package com.example.tudy.goal;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/goals")
@RequiredArgsConstructor
@Validated
@Tag(name = "Goal", description = "목표 관리 API")
public class GoalController {
    private final GoalService goalService;

    @PostMapping
    @Operation(
        summary = "목표 생성", 
        description = "새로운 목표를 생성합니다. proofType이 TIME일 때는 targetTime 설정이 필요하며, 최소 2시간(7200초) 이상이어야 합니다."
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "목표 생성 성공"),
        @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터"),
        @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음")
    })
    public ResponseEntity<Goal> create(@Valid @RequestBody GoalCreateRequest req) {
        Goal goal = goalService.createGoal(req);
        return ResponseEntity.ok(goal);
    }

    @PutMapping("/{id}")
    @Operation(
        summary = "목표 수정", 
        description = "기존 목표의 정보를 수정합니다."
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "목표 수정 성공"),
        @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터"),
        @ApiResponse(responseCode = "404", description = "목표를 찾을 수 없음")
    })
    public ResponseEntity<Goal> update(@PathVariable Long id, @Valid @RequestBody GoalCreateRequest req) {
        Goal goal = goalService.updateGoal(
                id,
                req.getTitle(),
                req.getCategoryName(),
                req.getStartDate(),
                req.getEndDate(),
                req.getIsGroupGoal(),
                req.getGroupId(),
                req.getIsFriendGoal(),
                req.getFriendName(),
                req.getProofType(),
                req.getTargetTime()
        );
        return ResponseEntity.ok(goal);
    }

    @DeleteMapping("/{id}")
    @Operation(
        summary = "목표 삭제", 
        description = "지정된 ID의 목표를 삭제합니다."
    )
    @ApiResponse(responseCode = "200", description = "목표 삭제 성공")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        goalService.deleteGoal(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping
    @Operation(
        summary = "목표 목록 조회", 
        description = "사용자의 모든 목표를 조회합니다. 카테고리별 필터링이 가능합니다."
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "목표 목록 조회 성공"),
        @ApiResponse(responseCode = "404", description = "사용자 또는 카테고리를 찾을 수 없음")
    })
    public ResponseEntity<List<Goal>> list(
            @RequestParam String userId, 
            @RequestParam(required = false) String categoryName) {
        return ResponseEntity.ok(goalService.listGoals(userId, categoryName));
    }

    @GetMapping("/by-date")
    @Operation(
        summary = "날짜별 목표 조회", 
        description = "특정 날짜의 목표를 조회합니다. 카테고리별 필터링이 가능합니다."
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "날짜별 목표 조회 성공"),
        @ApiResponse(responseCode = "400", description = "잘못된 날짜 형식"),
        @ApiResponse(responseCode = "404", description = "사용자 또는 카테고리를 찾을 수 없음")
    })
    public ResponseEntity<List<Goal>> listByDate(
            @RequestParam String userId, 
            @RequestParam("date") String dateStr, 
            @RequestParam(required = false) String categoryName) {
        LocalDate date = LocalDate.parse(dateStr);
        return ResponseEntity.ok(goalService.listGoalsByDate(userId, date, categoryName));
    }

    @PostMapping("/{id}/proof-image")
    @Operation(
        summary = "이미지 인증으로 목표 완료", 
        description = "이미지 인증 목표에 증명 이미지를 업로드하고 목표를 완료합니다."
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "이미지 인증 성공 및 목표 완료"),
        @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터"),
        @ApiResponse(responseCode = "404", description = "목표를 찾을 수 없음"),
        @ApiResponse(responseCode = "409", description = "이미지 인증 목표가 아님")
    })
    public ResponseEntity<Goal> uploadProofImage(@PathVariable Long id, @Valid @RequestBody ProofRequest req) {
        Goal goal = goalService.completeImageProofGoal(id, req.getProofImage());
        return ResponseEntity.ok(goal);
    }

    @Data
    private static class ProofRequest {
        @Schema(description = "증명 이미지 경로", example = "/images/proof.png")
        @NotBlank(message = "증명 이미지 경로는 필수입니다")
        private String proofImage;
    }

    @Data
    class SimpleGoalResponse {
        @Schema(description = "목표 제목", example = "매일 2시간 공부하기")
        private String title;
        
        @Schema(description = "완료 상태", example = "false")
        private boolean completed;
        
        @Schema(description = "친구 이름", example = "김철수")
        private String friendName;

        public SimpleGoalResponse(String title, boolean completed) {
            this.title = title;
            this.completed = completed;
        }

        public SimpleGoalResponse(String title, boolean completed, String friendName) {
            this.title = title;
            this.completed = completed;
            this.friendName = friendName;
        }
    }
}