package com.example.tudy.study;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class RankingResponse {
    private List<RankItem> rankings;

    @Data
    @AllArgsConstructor
    public static class RankItem {
        private String major;
        private Long score;
    }
}
