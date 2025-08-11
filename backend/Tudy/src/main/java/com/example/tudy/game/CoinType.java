package com.example.tudy.game;

public enum CoinType {
    ACADEMIC_SAEDO("학과&새도 코인"),
    GYM("체육관 코인"),
    CAFE("카페 코인");
    
    private final String displayName;
    
    CoinType(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
