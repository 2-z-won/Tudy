package com.example.tudy.diary;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DiaryResponseDTO {
    private LocalDate date;
    private String emoji;
    private String content;
}
