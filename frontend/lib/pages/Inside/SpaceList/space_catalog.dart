import 'package:flutter/foundation.dart';

class SpaceDef {
  final String id; // 내부 식별자 (영문)
  final String nameKor; // 표시 이름 (한글)
  final int price; // 코인 가격
  final int maxInstall; // 최대 설치 개수
    final int maxLevel;

  const SpaceDef({
    required this.id,
    required this.nameKor,
    required this.price,
    required this.maxInstall,
    this.maxLevel = 1
  });
}

/// 건물 타입
enum BuildingType { DEPARTMENT, LIBRARY, CAFE, GYM }

/// 카탈로그 정의 (네 SpaceType 주석 그룹 그대로 매핑)
class SpaceCatalog {
  // 학과 건물
 static const department = <SpaceDef>[
  SpaceDef(id: 'LECTURE',     nameKor: '강의실',   price: 500,  maxInstall: 3, maxLevel: 3),
  SpaceDef(id: 'MAJOR_ROOM',  nameKor: '과방',     price: 1200, maxInstall: 3, maxLevel: 3),
  SpaceDef(id: 'OFFICE',      nameKor: '학과사무실', price: 800, maxInstall: 2, maxLevel: 2),
  SpaceDef(id: 'MAJOR_LAB',   nameKor: '전공실',   price: 1000, maxInstall: 2, maxLevel: 2),
  SpaceDef(id: 'BATHROOM',    nameKor: '화장실',   price: 500,  maxInstall: 1), // 기본 1
  SpaceDef(id: 'SEMINAR',     nameKor: '세미나실', price: 800,  maxInstall: 2, maxLevel: 2),
];

  // 도서관
  static const library = <SpaceDef>[
    SpaceDef(id: 'STUDY_ROOM', nameKor: '스터디룸', price: 500, maxInstall: 2),
    SpaceDef(id: 'LIBRARY_HALL', nameKor: '새벽벌당', price: 1000, maxInstall: 2),
    SpaceDef(id: 'LIBRARY_CAFE', nameKor: '카페', price: 800, maxInstall: 2),
    SpaceDef(id: 'READING_ROOM', nameKor: '열람실', price: 500, maxInstall: 2),
    SpaceDef(id: 'LAPTOP_ROOM', nameKor: '노트북 열람실', price: 600, maxInstall: 2),
  ];

  // 체육관
  static const gym = <SpaceDef>[
    SpaceDef(id: 'COUNTER', nameKor: '카운터', price: 500, maxInstall: 1),
    SpaceDef(id: 'STRETCHING', nameKor: '스트레칭실', price: 600, maxInstall: 2),
    SpaceDef(id: 'SHOWER', nameKor: '샤워실', price: 500, maxInstall: 1),
    SpaceDef(
      id: 'WORKOUT_ZONE',
      nameKor: '오운완 zone',
      price: 1000,
      maxInstall: 2,
    ),
    SpaceDef(id: 'EQUIPMENT', nameKor: '기구', price: 800, maxInstall: 2),
  ];

  // 카페
  static const cafe = <SpaceDef>[
    SpaceDef(id: 'CAFE_COUNTER', nameKor: '카운터', price: 500, maxInstall: 1),
    SpaceDef(id: 'WAREHOUSE', nameKor: '창고', price: 300, maxInstall: 1),
    SpaceDef(id: 'TABLE_SEAT', nameKor: '테이블 좌석', price: 600, maxInstall: 2),
    SpaceDef(id: 'DESSERT', nameKor: '디저트', price: 400, maxInstall: 2, maxLevel: 3),
  ];

  static List<SpaceDef> byBuilding(BuildingType t) {
    switch (t) {
      case BuildingType.DEPARTMENT:
        return department;
      case BuildingType.LIBRARY:
        return library;
      case BuildingType.GYM:
        return gym;
      case BuildingType.CAFE:
        return cafe;
    }
  }
}
