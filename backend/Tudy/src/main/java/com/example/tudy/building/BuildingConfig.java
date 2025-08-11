package com.example.tudy.building;

import java.util.HashMap;
import java.util.Map;

public class BuildingConfig {
    
    // 건물별 층수와 칸 수
    private static final Map<BuildingType, BuildingInfo> BUILDING_INFO = new HashMap<>();
    
    static {
        // 학과 건물: 5층, 각 층 2칸
        BUILDING_INFO.put(BuildingType.DEPARTMENT, new BuildingInfo(5, 2, 3));
        
        // 도서관: 4층, 각 층 2칸
        BUILDING_INFO.put(BuildingType.LIBRARY, new BuildingInfo(4, 2, 3));
        
        // 체육관: 3층, 각 층 2칸
        BUILDING_INFO.put(BuildingType.GYM, new BuildingInfo(3, 2, 3));
        
        // 카페: 2층, 각 층 2칸
        BUILDING_INFO.put(BuildingType.CAFE, new BuildingInfo(2, 2, 2));
    }
    
    public static BuildingInfo getBuildingInfo(BuildingType buildingType) {
        return BUILDING_INFO.get(buildingType);
    }
    
    public static class BuildingInfo {
        private final int floors;
        private final int slotsPerFloor;
        private final int exteriorUpgradeFloor;
        
        public BuildingInfo(int floors, int slotsPerFloor, int exteriorUpgradeFloor) {
            this.floors = floors;
            this.slotsPerFloor = slotsPerFloor;
            this.exteriorUpgradeFloor = exteriorUpgradeFloor;
        }
        
        public int getFloors() {
            return floors;
        }
        
        public int getSlotsPerFloor() {
            return slotsPerFloor;
        }
        
        public int getExteriorUpgradeFloor() {
            return exteriorUpgradeFloor;
        }
        
        public int getTotalSlots() {
            return floors * slotsPerFloor;
        }
    }
}
