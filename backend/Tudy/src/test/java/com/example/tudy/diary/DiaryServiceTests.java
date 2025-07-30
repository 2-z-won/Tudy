package com.example.tudy.diary;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
class DiaryServiceTests {

    @Autowired
    DiaryRepository diaryRepository;

    @Test
    @DisplayName("Save and find diary by date")
    void saveAndFind() {
        Diary diary = new Diary();
        diary.setDate(LocalDate.of(2024,1,1));
        diary.setEmoji("😀");
        diary.setContent("test");
        diaryRepository.save(diary);

        assertThat(diaryRepository.findByDate(LocalDate.of(2024,1,1))).isPresent();
    }
}
