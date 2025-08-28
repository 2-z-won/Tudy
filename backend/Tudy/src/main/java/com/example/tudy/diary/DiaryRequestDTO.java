package com.example.tudy.diary;

import lombok.Data;

import java.time.LocalDate;

@Data
public class DiaryRequestDTO {
    private String userId; // 사용자 ID 추가
    private LocalDate date;
    private String emoji;
    private String content;
}
