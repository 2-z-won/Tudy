package com.example.tudy.building;

import com.example.tudy.user.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "user_buildings")
@Getter
@Setter
@NoArgsConstructor
public class UserBuilding {
    
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
    private Integer currentFloor = 1;
    
    @Column(nullable = false)
    private Boolean exteriorUpgraded = false;
    
    public UserBuilding(User user, BuildingType buildingType) {
        this.user = user;
        this.buildingType = buildingType;
        this.currentFloor = 1;
        this.exteriorUpgraded = false;
    }
    
    public void expandFloor() {
        if (this.currentFloor < BuildingConfig.getBuildingInfo(this.buildingType).getFloors()) {
            this.currentFloor++;
        }
    }
    
    public void upgradeExterior() {
        this.exteriorUpgraded = true;
    }
    
    public boolean canUpgradeExterior() {
        BuildingConfig.BuildingInfo info = BuildingConfig.getBuildingInfo(this.buildingType);
        return this.currentFloor >= info.getExteriorUpgradeFloor() && !this.exteriorUpgraded;
    }
}
