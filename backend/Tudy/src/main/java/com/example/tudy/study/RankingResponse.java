package com.example.tudy.study;

import java.util.List;

/**
 * Response wrapper for study session ranking.
 * Contains a list of ranked items for each user.
 */
public record RankingResponse(List<RankItem> ranking) {

    /**
     * Individual ranking item containing user info and accumulated score.
     *
     * @param userId   unique user identifier
     * @param nickname user's nickname
     * @param score    accumulated study duration in seconds
     */
    public record RankItem(String userId, String nickname, Long score) {
    }
}

