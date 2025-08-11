package com.example.tudy.building;

public enum SpaceType {
    // 학과 건물
    LECTURE("강의실", 500, 3),
    MAJOR_ROOM("과방", 1200, 3),
    OFFICE("학과사무실", 800, 2),
    MAJOR_LAB("전공실", 1000, 1),
    BATHROOM("화장실", 500, 1),
    SEMINAR("세미나실", 800, 2),
    
    // 도서관
    STUDY_ROOM("스터디룸", 500, 1),
    LIBRARY_HALL("새벽벌당", 1000, 1),
    LIBRARY_CAFE("카페", 800, 1),
    READING_ROOM("열람실", 500, 1),
    LAPTOP_ROOM("노트북 열람실", 600, 1),
    
    // 체육관
    COUNTER("카운터", 500, 1),
    STRETCHING("스트레칭실", 600, 1),
    SHOWER("샤워실", 500, 1),
    WORKOUT_ZONE("오운완 zone", 1000, 1),
    EQUIPMENT("기구", 800, 1),
    
    // 카페
    CAFE_COUNTER("카운터", 500, 1),
    WAREHOUSE("창고", 300, 1),
    TABLE_SEAT("테이블 좌석", 600, 1),
    DESSERT("디저트", 400, 3);
    
    private final String displayName;
    private final int basePrice;
    private final int maxLevel;
    
    SpaceType(String displayName, int basePrice, int maxLevel) {
        this.displayName = displayName;
        this.basePrice = basePrice;
        this.maxLevel = maxLevel;
    }
    
    public String getDisplayName() {
        return displayName;
    }
    
    public int getBasePrice() {
        return basePrice;
    }
    
    public int getMaxLevel() {
        return maxLevel;
    }
    
    public int getUpgradePrice() {
        return basePrice / 2;
    }
}
