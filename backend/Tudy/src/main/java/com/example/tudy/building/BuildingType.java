package com.example.tudy.building;

public enum BuildingType {
    DEPARTMENT("학과 건물"),
    LIBRARY("새벽벌 도서관"),
    GYM("체육관"),
    CAFE("카페");
    
    private final String displayName;
    
    BuildingType(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
