package com.example.tudy.building;

import com.example.tudy.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserBuildingRepository extends JpaRepository<UserBuilding, Long> {
    
    List<UserBuilding> findByUser(User user);
    
    Optional<UserBuilding> findByUserAndBuildingType(User user, BuildingType buildingType);
    
    boolean existsByUserAndBuildingType(User user, BuildingType buildingType);
}
