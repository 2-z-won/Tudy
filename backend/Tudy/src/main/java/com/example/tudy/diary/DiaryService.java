package com.example.tudy.diary;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class DiaryService {
    private final DiaryRepository diaryRepository;

    public DiaryResponseDTO getDiaryByDate(LocalDate date) {
        return diaryRepository.findByDate(date)
                .map(d -> new DiaryResponseDTO(d.getDate(), d.getEmoji(), d.getContent()))
                .orElse(new DiaryResponseDTO(date, "\uD83D\uDCDD", "아직 작성된 일기가 없습니다."));
    }

    public DiaryResponseDTO saveOrUpdateDiary(DiaryRequestDTO dto) {
        Diary diary = diaryRepository.findByDate(dto.getDate()).orElse(new Diary());
        diary.setDate(dto.getDate());
        diary.setEmoji(dto.getEmoji());
        diary.setContent(dto.getContent());
        Diary saved = diaryRepository.save(diary);
        return new DiaryResponseDTO(saved.getDate(), saved.getEmoji(), saved.getContent());
    }
}
