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
     * 구매한 슬롯만 반환 (초기 슬롯 자동 생성 제거)
     */
    public List<UserBuildingSlot> getUserBuildingSlots(User user, BuildingType buildingType) {
        UserBuilding building = getUserBuilding(user, buildingType);
        return userBuildingSlotRepository.findByUserAndBuildingTypeOrderBySlotNumber(user, buildingType);
    }
    
    /**
     * 특정 슬롯 조회 (없으면 생성)
     */
    public UserBuildingSlot getSlot(User user, BuildingType buildingType, Integer slotNumber) {
        return userBuildingSlotRepository.findByUserAndBuildingTypeAndSlotNumber(user, buildingType, slotNumber)
                .orElseGet(() -> {
                    // 해당 슬롯이 없으면 빈 슬롯 생성
                    UserBuildingSlot slot = new UserBuildingSlot(user, buildingType, slotNumber);
                    return userBuildingSlotRepository.save(slot);
                });
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
        
        // 해당 슬롯 번호가 이미 사용 중인지 확인
        boolean slotInUse = userBuildingSlotRepository.findByUserAndBuildingTypeAndSlotNumber(user, buildingType, slotNumber)
                .map(UserBuildingSlot::getIsInstalled)
                .orElse(false);
        
        if (slotInUse) {
            throw new IllegalStateException("해당 슬롯은 이미 사용 중입니다.");
        }

        // 구매한 슬롯에 slotNumber 설정하고 설치
        purchasedSlot.setSlotNumber(slotNumber);
        purchasedSlot.install(purchasedSlot.getPurchasedSpaceType());
        userBuildingSlotRepository.save(purchasedSlot);
        
        // 층 확장 체크
        checkFloorExpansion(user, buildingType);
        
        return purchasedSlot;
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
     * 공간 업그레이드 (slotId로)
     */
    public UserBuildingSlot upgradeSpaceById(User user, BuildingType buildingType, Long slotId) {
        UserBuildingSlot slot = userBuildingSlotRepository.findById(slotId)
                .orElseThrow(() -> new IllegalArgumentException("슬롯을 찾을 수 없습니다."));
        
        // 사용자와 건물 타입이 일치하는지 확인
        if (!slot.getUser().getId().equals(user.getId()) || !slot.getBuildingType().equals(buildingType)) {
            throw new IllegalArgumentException("해당 슬롯에 접근할 권한이 없습니다.");
        }
        
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
        
        // 현재 층의 각 슬롯 번호에 대해 설치된 슬롯이 있는지 확인
        boolean allSlotsInstalled = true;
        for (int slotNumber = startSlot; slotNumber <= endSlot; slotNumber++) {
            boolean slotInstalled = userBuildingSlotRepository
                    .findByUserAndBuildingTypeAndSlotNumber(user, buildingType, slotNumber)
                    .map(UserBuildingSlot::getIsInstalled)
                    .orElse(false);
            
            if (!slotInstalled) {
                allSlotsInstalled = false;
                break;
            }
        }
        
        // 모든 슬롯이 설치되었으면 다음 층 열기
        if (allSlotsInstalled) {
            building.expandFloor();
            userBuildingRepository.save(building);
        }
    }
}
