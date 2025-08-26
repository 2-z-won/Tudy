package com.example.tudy.building;

import com.example.tudy.game.CoinService;
import com.example.tudy.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class BuildingService {
    
    private final UserBuildingRepository userBuildingRepository;
    private final UserBuildingSlotRepository userBuildingSlotRepository;
    private final CoinService coinService;
    
    /**
     * 사용자의 특정 건물 정보 조회 (없으면 생성)
     */
    public UserBuilding getUserBuilding(User user, BuildingType buildingType) {
        return userBuildingRepository.findByUserAndBuildingType(user, buildingType)
                .orElseGet(() -> createInitialBuilding(user, buildingType));
    }
    
    /**
     * 사용자의 특정 건물의 모든 슬롯 조회
     */
    public List<UserBuildingSlot> getUserBuildingSlots(User user, BuildingType buildingType) {
        UserBuilding building = getUserBuilding(user, buildingType);
        List<UserBuildingSlot> slots = userBuildingSlotRepository.findByUserAndBuildingTypeOrderBySlotNumber(user, buildingType);
        
        // 슬롯이 없으면 초기 슬롯들 생성
        if (slots.isEmpty()) {
            slots = createInitialSlots(user, buildingType);
        }
        
        return slots;
    }
    
    /**
     * 특정 슬롯 조회
     */
    public UserBuildingSlot getSlot(User user, BuildingType buildingType, Integer slotNumber) {
        return userBuildingSlotRepository.findByUserAndBuildingTypeAndSlotNumber(user, buildingType, slotNumber)
                .orElseThrow(() -> new IllegalArgumentException("슬롯을 찾을 수 없습니다."));
    }
    
    /**
     * 공간 구매 (슬롯과 무관하게 공간만 구매)
     */
    public UserBuildingSlot purchaseSpace(User user, BuildingType buildingType, SpaceType spaceType) {
        // 코인 차감
        coinService.subtractCoins(user, spaceType.getBasePrice());
        
        // 새로운 슬롯 생성 (slotNumber는 null, 구매만 완료)
        UserBuildingSlot slot = new UserBuildingSlot(user, buildingType, null);
        slot.purchase(spaceType);
        // 즉시 flush하여 제약조건 위반 시 예외를 컨트롤러에서 처리
        userBuildingSlotRepository.saveAndFlush(slot);

        return slot;
    }
    
    /**
     * 공간 설치 (구매한 슬롯 ID로)
     */
    public UserBuildingSlot installSpace(User user, BuildingType buildingType, Long purchasedSlotId, Integer slotNumber) {
        UserBuildingSlot purchasedSlot = userBuildingSlotRepository.findById(purchasedSlotId)
                .orElseThrow(() -> new IllegalArgumentException("구매한 슬롯을 찾을 수 없습니다."));
        
        // 사용자와 건물 타입이 일치하는지 확인
        if (!purchasedSlot.getUser().getId().equals(user.getId()) || !purchasedSlot.getBuildingType().equals(buildingType)) {
            throw new IllegalArgumentException("해당 슬롯에 접근할 권한이 없습니다.");
        }
        
        if (purchasedSlot.getIsInstalled()) {
            throw new IllegalStateException("이미 설치된 슬롯입니다.");
        }
        
        if (purchasedSlot.getPurchasedSpaceType() == null) {
            throw new IllegalStateException("먼저 공간을 구매해야 합니다.");
        }
        
        // 설치할 슬롯이 사용 가능한지 확인
        UserBuildingSlot targetSlot = getSlot(user, buildingType, slotNumber);
        if (targetSlot.getIsInstalled()) {
            throw new IllegalStateException("해당 슬롯은 이미 사용 중입니다.");
        }
        
        // 공간 설치 (코인은 이미 구매 시 차감됨)
        targetSlot.install(purchasedSlot.getPurchasedSpaceType());
        userBuildingSlotRepository.save(targetSlot);

        // 구매한 슬롯 삭제 후 즉시 flush하여 예외를 조기에 감지
        userBuildingSlotRepository.delete(purchasedSlot);
        userBuildingSlotRepository.flush();
        
        // 층 확장 체크
        checkFloorExpansion(user, buildingType);
        
        return targetSlot;
    }
    
    /**
     * 공간 업그레이드
     */
    public UserBuildingSlot upgradeSpace(User user, BuildingType buildingType, Integer slotNumber) {
        UserBuildingSlot slot = getSlot(user, buildingType, slotNumber);
        
        if (!slot.canUpgrade()) {
            throw new IllegalStateException("업그레이드할 수 없습니다.");
        }
        
        // 코인 차감
        coinService.subtractCoins(user, slot.getSpaceType().getUpgradePrice());
        
        // 업그레이드
        slot.upgrade();
        userBuildingSlotRepository.save(slot);
        
        return slot;
    }
    
    /**
     * 외관 업그레이드
     */
    public UserBuilding upgradeExterior(User user, BuildingType buildingType) {
        UserBuilding building = getUserBuilding(user, buildingType);
        
        if (!building.canUpgradeExterior()) {
            throw new IllegalStateException("외관 업그레이드 조건을 만족하지 않습니다.");
        }
        
        building.upgradeExterior();
        return userBuildingRepository.save(building);
    }
    
    /**
     * 초기 건물 생성
     */
    private UserBuilding createInitialBuilding(User user, BuildingType buildingType) {
        UserBuilding building = new UserBuilding(user, buildingType);
        return userBuildingRepository.save(building);
    }
    
    /**
     * 초기 슬롯들 생성
     */
    private List<UserBuildingSlot> createInitialSlots(User user, BuildingType buildingType) {
        BuildingConfig.BuildingInfo info = BuildingConfig.getBuildingInfo(buildingType);
        int totalSlots = info.getTotalSlots();
        
        List<UserBuildingSlot> slots = new java.util.ArrayList<>();
        for (int i = 1; i <= totalSlots; i++) {
            UserBuildingSlot slot = new UserBuildingSlot(user, buildingType, i);
            slots.add(userBuildingSlotRepository.save(slot));
        }
        
        return slots;
    }
    
    /**
     * 층 확장 체크
     */
    private void checkFloorExpansion(User user, BuildingType buildingType) {
        UserBuilding building = getUserBuilding(user, buildingType);
        BuildingConfig.BuildingInfo info = BuildingConfig.getBuildingInfo(buildingType);
        
        // 현재 층의 모든 슬롯이 설치되었는지 확인
        int currentFloor = building.getCurrentFloor();
        int slotsPerFloor = info.getSlotsPerFloor();
        int startSlot = (currentFloor - 1) * slotsPerFloor + 1;
        int endSlot = currentFloor * slotsPerFloor;
        
        List<UserBuildingSlot> currentFloorSlots = userBuildingSlotRepository
                .findByUserAndBuildingTypeOrderBySlotNumber(user, buildingType)
                .stream()
                .filter(slot -> slot.getSlotNumber() >= startSlot && slot.getSlotNumber() <= endSlot)
                .toList();
        
        // 모든 슬롯이 설치되었으면 다음 층 열기
        if (currentFloorSlots.stream().allMatch(UserBuildingSlot::getIsInstalled)) {
            building.expandFloor();
            userBuildingRepository.save(building);
        }
    }
}
