package com.example.tudy.building;

import com.example.tudy.user.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "user_building_slots")
@Getter
@Setter
@NoArgsConstructor
public class UserBuildingSlot {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private BuildingType buildingType;
    
    @Column(nullable = false)
    private Integer slotNumber;
    
    @Enumerated(EnumType.STRING)
    private SpaceType spaceType;
    
    @Enumerated(EnumType.STRING)
    private SpaceType purchasedSpaceType;  // 구매한 공간 타입 (설치 전)
    
    @Column(nullable = false)
    private Integer currentLevel = 0;
    
    @Column(nullable = false)
    private Boolean isInstalled = false;
    
    public UserBuildingSlot(User user, BuildingType buildingType, Integer slotNumber) {
        this.user = user;
        this.buildingType = buildingType;
        this.slotNumber = slotNumber;
        this.currentLevel = 0;
        this.isInstalled = false;
    }
    
    public void install(SpaceType spaceType) {
        this.spaceType = spaceType;
        this.currentLevel = 1;
        this.isInstalled = true;
    }
    
    public void purchase(SpaceType spaceType) {
        this.purchasedSpaceType = spaceType;
        this.isInstalled = false;
    }
    
    public void upgrade() {
        if (this.isInstalled && this.spaceType != null) {
            if (this.currentLevel < this.spaceType.getMaxLevel()) {
                this.currentLevel++;
            }
        }
    }
    
    public boolean canUpgrade() {
        return this.isInstalled && this.spaceType != null && 
               this.currentLevel < this.spaceType.getMaxLevel();
    }
    
    public int getFloor() {
        return ((slotNumber - 1) / BuildingConfig.getBuildingInfo(buildingType).getSlotsPerFloor()) + 1;
    }
    
    public int getPositionInFloor() {
        return ((slotNumber - 1) % BuildingConfig.getBuildingInfo(buildingType).getSlotsPerFloor()) + 1;
    }
}
