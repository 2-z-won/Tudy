package com.example.tudy.diary;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/diary")
@RequiredArgsConstructor
@Tag(name = "Diary", description = "Diary APIs")
public class DiaryController {
    private final DiaryService diaryService;

    @GetMapping
    @Operation(summary = "Get diary by date")
    public ResponseEntity<DiaryResponseDTO> getDiary(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(diaryService.getDiaryByDate(date));
    }

    @PostMapping
    @Operation(summary = "Create or update diary")
    public ResponseEntity<DiaryResponseDTO> createOrUpdate(@RequestBody DiaryRequestDTO dto) {
        return ResponseEntity.ok(diaryService.saveOrUpdateDiary(dto));
    }
}
