package com.example.tudy.diary;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import com.example.tudy.user.UserRepository;
import com.example.tudy.user.User;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class DiaryService {
    private final DiaryRepository diaryRepository;
    private final UserRepository userRepository;

    public DiaryResponseDTO getDiaryByDate(String userId, LocalDate date) {
        return diaryRepository.findByUser_UserIdAndDate(userId, date)
                .map(d -> new DiaryResponseDTO(d.getDate(), d.getEmoji(), d.getContent()))
                .orElse(new DiaryResponseDTO(date, "\uD83D\uDCDD", "아직 작성된 일기가 없습니다."));
    }

    public DiaryResponseDTO saveOrUpdateDiary(DiaryRequestDTO dto) {
        User user = userRepository.findByUserId(dto.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Diary diary = diaryRepository.findByUser_UserIdAndDate(dto.getUserId(), dto.getDate())
                .orElse(new Diary());
        
        diary.setUser(user);
        diary.setDate(dto.getDate());
        diary.setEmoji(dto.getEmoji());
        diary.setContent(dto.getContent());
        
        Diary saved = diaryRepository.save(diary);
        return new DiaryResponseDTO(saved.getDate(), saved.getEmoji(), saved.getContent());
    }
}
