package com.example.tudy.building;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserBuildingSlotRepository extends JpaRepository<UserBuildingSlot, Long> {
    
    List<UserBuildingSlot> findByUserAndBuildingType(User user, BuildingType buildingType);
    
    Optional<UserBuildingSlot> findByUserAndBuildingTypeAndSlotNumber(User user, BuildingType buildingType, Integer slotNumber);
    
    List<UserBuildingSlot> findByUserAndBuildingTypeOrderBySlotNumber(User user, BuildingType buildingType);
}
