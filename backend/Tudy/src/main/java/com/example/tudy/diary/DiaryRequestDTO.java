package com.example.tudy.diary;

import lombok.Data;

import java.time.LocalDate;

@Data
public class DiaryRequestDTO {
    private LocalDate date;
    private String emoji;
    private String content;
}
