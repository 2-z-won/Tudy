package com.example.tudy.building;

import com.example.tudy.user.User;
import com.example.tudy.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users/{userId}/buildings")
@RequiredArgsConstructor
public class BuildingController {
    
    private final BuildingService buildingService;
    private final UserService userService;
    
    /**
     * 유저 건물 전체 조회
     */
    @GetMapping("/{buildingType}")
    public ResponseEntity<BuildingResponse> getUserBuilding(
            @PathVariable String userId,
            @PathVariable BuildingType buildingType,
            Authentication authentication) {
        
        // 인증된 사용자 확인
        User authenticatedUser = userService.getUserByEmail(authentication.getName());
        User targetUser = userService.findByUserId(userId);
        
        if (!authenticatedUser.getId().equals(targetUser.getId())) {
            return ResponseEntity.status(403).body(null);
        }
        
        // 건물 정보 조회
        UserBuilding building = buildingService.getUserBuilding(targetUser, buildingType);
        List<UserBuildingSlot> slots = buildingService.getUserBuildingSlots(targetUser, buildingType);
        
        BuildingResponse response = new BuildingResponse();
        response.setBuilding(building);
        response.setSlots(slots);
        response.setBuildingConfig(BuildingConfig.getBuildingInfo(buildingType));
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 특정 칸 조회
     */
    @GetMapping("/{buildingType}/slots/{slotNumber}")
    public ResponseEntity<UserBuildingSlot> getSlot(
            @PathVariable String userId,
            @PathVariable BuildingType buildingType,
            @PathVariable Integer slotNumber,
            Authentication authentication) {
        
        User authenticatedUser = userService.getUserByEmail(authentication.getName());
        User targetUser = userService.findByUserId(userId);
        
        if (!authenticatedUser.getId().equals(targetUser.getId())) {
            return ResponseEntity.status(403).body(null);
        }
        
        UserBuildingSlot slot = buildingService.getSlot(targetUser, buildingType, slotNumber);
        return ResponseEntity.ok(slot);
    }
    
    /**
     * 공간 설치
     */
    @PostMapping("/{buildingType}/slots/{slotNumber}/install")
    public ResponseEntity<UserBuildingSlot> installSpace(
            @PathVariable String userId,
            @PathVariable BuildingType buildingType,
            @PathVariable Integer slotNumber,
            @RequestBody InstallRequest request,
            Authentication authentication) {
        
        User authenticatedUser = userService.getUserByEmail(authentication.getName());
        User targetUser = userService.findByUserId(userId);
        
        if (!authenticatedUser.getId().equals(targetUser.getId())) {
            return ResponseEntity.status(403).body(null);
        }
        
        try {
            UserBuildingSlot slot = buildingService.installSpace(targetUser, buildingType, slotNumber, request.getSpaceType());
            return ResponseEntity.ok(slot);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    /**
     * 공간 업그레이드
     */
    @PostMapping("/{buildingType}/slots/{slotNumber}/upgrade")
    public ResponseEntity<UserBuildingSlot> upgradeSpace(
            @PathVariable String userId,
            @PathVariable BuildingType buildingType,
            @PathVariable Integer slotNumber,
            Authentication authentication) {
        
        User authenticatedUser = userService.getUserByEmail(authentication.getName());
        User targetUser = userService.findByUserId(userId);
        
        if (!authenticatedUser.getId().equals(targetUser.getId())) {
            return ResponseEntity.status(403).body(null);
        }
        
        try {
            UserBuildingSlot slot = buildingService.upgradeSpace(targetUser, buildingType, slotNumber);
            return ResponseEntity.ok(slot);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    /**
     * 외관 업그레이드
     */
    @PostMapping("/{buildingType}/exterior/upgrade")
    public ResponseEntity<UserBuilding> upgradeExterior(
            @PathVariable String userId,
            @PathVariable BuildingType buildingType,
            Authentication authentication) {
        
        User authenticatedUser = userService.getUserByEmail(authentication.getName());
        User targetUser = userService.findByUserId(userId);
        
        if (!authenticatedUser.getId().equals(targetUser.getId())) {
            return ResponseEntity.status(403).body(null);
        }
        
        try {
            UserBuilding building = buildingService.upgradeExterior(targetUser, buildingType);
            return ResponseEntity.ok(building);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    /**
     * 공간/단계별 설정값 조회
     */
    @GetMapping("/{buildingType}/spaces/config")
    public ResponseEntity<Map<String, Object>> getSpaceConfig(@PathVariable BuildingType buildingType) {
        Map<String, Object> config = Map.of(
            "buildingType", buildingType.name(),
            "displayName", buildingType.getDisplayName(),
            "floors", BuildingConfig.getBuildingInfo(buildingType).getFloors(),
            "slotsPerFloor", BuildingConfig.getBuildingInfo(buildingType).getSlotsPerFloor(),
            "exteriorUpgradeFloor", BuildingConfig.getBuildingInfo(buildingType).getExteriorUpgradeFloor(),
            "spaces", java.util.Arrays.stream(SpaceType.values())
                .filter(space -> isSpaceForBuilding(space, buildingType))
                .collect(Collectors.toMap(
                    SpaceType::name,
                    space -> Map.of(
                        "displayName", space.getDisplayName(),
                        "basePrice", space.getBasePrice(),
                        "upgradePrice", space.getUpgradePrice(),
                        "maxLevel", space.getMaxLevel()
                    )
                ))
        );
        
        return ResponseEntity.ok(config);
    }
    
    /**
     * 건물 타입에 맞는 공간인지 확인
     */
    private boolean isSpaceForBuilding(SpaceType spaceType, BuildingType buildingType) {
        return switch (buildingType) {
            case DEPARTMENT -> spaceType.name().startsWith("LECTURE") || 
                              spaceType.name().startsWith("MAJOR") || 
                              spaceType.name().startsWith("OFFICE") || 
                              spaceType.name().startsWith("BATHROOM") || 
                              spaceType.name().startsWith("SEMINAR");
            case LIBRARY -> spaceType.name().startsWith("STUDY") || 
                           spaceType.name().startsWith("LIBRARY") || 
                           spaceType.name().startsWith("READING") || 
                           spaceType.name().startsWith("LAPTOP");
            case GYM -> spaceType.name().startsWith("COUNTER") || 
                       spaceType.name().startsWith("STRETCHING") || 
                       spaceType.name().startsWith("SHOWER") || 
                       spaceType.name().startsWith("WORKOUT") || 
                       spaceType.name().startsWith("EQUIPMENT");
            case CAFE -> spaceType.name().startsWith("CAFE") || 
                        spaceType.name().startsWith("WAREHOUSE") || 
                        spaceType.name().startsWith("TABLE") || 
                        spaceType.name().startsWith("DESSERT");
        };
    }
    
    /**
     * 건물 응답 DTO
     */
    public static class BuildingResponse {
        private UserBuilding building;
        private List<UserBuildingSlot> slots;
        private BuildingConfig.BuildingInfo buildingConfig;
        
        // Getters and Setters
        public UserBuilding getBuilding() { return building; }
        public void setBuilding(UserBuilding building) { this.building = building; }
        
        public List<UserBuildingSlot> getSlots() { return slots; }
        public void setSlots(List<UserBuildingSlot> slots) { this.slots = slots; }
        
        public BuildingConfig.BuildingInfo getBuildingConfig() { return buildingConfig; }
        public void setBuildingConfig(BuildingConfig.BuildingInfo buildingConfig) { this.buildingConfig = buildingConfig; }
    }
    
    /**
     * 공간 설치 요청 DTO
     */
    public static class InstallRequest {
        private SpaceType spaceType;
        
        public SpaceType getSpaceType() { return spaceType; }
        public void setSpaceType(SpaceType spaceType) { this.spaceType = spaceType; }
    }
}
