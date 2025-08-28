import 'package:flutter/foundation.dart';
import 'package:frontend/pages/Inside/SpaceList/space_catalog.dart';

class BuildingInfo {
  final Building building;
  final List<Slot> slots;
  final BuildingConfig config;

  BuildingInfo({
    required this.building,
    required this.slots,
    required this.config,
  });

  factory BuildingInfo.fromJson(Map<String, dynamic> json) {
    return BuildingInfo(
      building: Building.fromJson(json['building'] as Map<String, dynamic>),
      slots: (json['slots'] as List)
          .map((e) => Slot.fromJson(e as Map<String, dynamic>))
          .toList(),
      config: BuildingConfig.fromJson(
        json['buildingConfig'] as Map<String, dynamic>,
      ),
    );
  }
}

class Building {
  final int id;
  final BuildingType buildingType;
  final int currentFloor;
  final bool exteriorUpgraded;

  Building({
    required this.id,
    required this.buildingType,
    required this.currentFloor,
    required this.exteriorUpgraded,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as int,
      buildingType: BuildingType.values.firstWhere(
        (e) => e.name == json['buildingType'],
        orElse: () => BuildingType.DEPARTMENT,
      ),

      currentFloor: json['currentFloor'] as int,
      exteriorUpgraded: json['exteriorUpgraded'] as bool,
    );
  }
}

class Slot {
  final int id;
  final int? slotNumber; // null = 구매했지만 미설치
  final String spaceType; // 서버 SpaceType 문자열 (예: LECTURE, MAJOR_LAB)
  final int currentLevel;

  Slot({
    required this.id,
    required this.slotNumber,
    required this.spaceType,
    required this.currentLevel,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'] as int,
      slotNumber: json['slotNumber'] == null ? null : json['slotNumber'] as int,
      spaceType: json['spaceType'] as String,
      currentLevel: json['currentLevel'] as int,
    );
  }
}

class BuildingConfig {
  final int floors;
  final int slotsPerFloor;
  final int exteriorUpgradeFloor;

  BuildingConfig({
    required this.floors,
    required this.slotsPerFloor,
    required this.exteriorUpgradeFloor,
  });

  factory BuildingConfig.fromJson(Map<String, dynamic> json) {
    return BuildingConfig(
      floors: json['floors'] as int,
      slotsPerFloor: json['slotsPerFloor'] as int,
      exteriorUpgradeFloor: json['exteriorUpgradeFloor'] as int,
    );
  }
}
