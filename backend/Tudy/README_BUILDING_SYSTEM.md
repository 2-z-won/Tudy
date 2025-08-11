# 🏗️ Tudy 건물 시스템

Tudy 프로젝트에 추가된 건물 시스템에 대한 설명입니다.

## 🏢 **건물 종류 및 층 구조**

### 1. **학과 건물 (5층)**
```
9  10   ← 5층
7   8   ← 4층
5   6   ← 3층
3   4   ← 2층
1   2   ← 1층
```

**공간 종류 및 가격:**
- **강의실** (3단계): 칠판&좌석 → 빔프로젝터 → 교수 - **500코인**
- **과방** (3단계): 테이블 → TV → 동방 - **1200코인**
- **학과사무실** (2단계): 사무실 → 라운지 - **800코인**
- **전공실** (1단계): 기본 - **1000코인**
- **화장실** (1단계): 기본 - **500코인**
- **세미나실** (2단계): 마이크&좌석 → 빔프로젝터 - **800코인**

### 2. **새벽벌 도서관 (4층)**
```
7  8
5  6
3  4
1  2
```

**공간 종류:**
- **스터디룸** - **500코인**
- **새벽벌당** - **1000코인**
- **카페** - **800코인**
- **열람실** - **500코인**
- **노트북 열람실** - **600코인**

### 3. **체육관 (3층)**
```
5  6
3  4
1  2
```

**공간 종류:**
- **카운터** - **500코인**
- **스트레칭실** - **600코인**
- **샤워실** - **500코인**
- **오운완 zone** - **1000코인**
- **기구** - **800코인**

### 4. **카페 (2층)**
```
3  4
1  2
```

**공간 종류:**
- **카운터** - **500코인**
- **창고** - **300코인**
- **테이블 좌석** - **600코인**
- **디저트** (1/2/3단계) - **400/600/800코인**

## 🔄 **시스템 규칙**

### **내부 층 확장**
- 1층(위치 1,2) 다 채우면 2층(3,4) 자동으로 열림
- 3층, 4층, 5층도 같은 규칙

### **외부 업그레이드**
- **카페**: 2층 확장 시 외관 업그레이드 가능
- **학과 건물, 체육관, 도서관**: 3층 확장 시 외관 업그레이드 가능
- 업그레이드는 **무료**, 버튼 클릭 시 진행

## 🏗️ **시스템 구조**

### **핵심 클래스들**
- `BuildingType` - 건물 타입 enum
- `SpaceType` - 공간 타입 enum (가격, 최대 레벨 포함)
- `BuildingConfig` - 건물별 설정 정보
- `UserBuilding` - 사용자 건물 정보
- `UserBuildingSlot` - 건물의 각 칸(슬롯)
- `BuildingService` - 건물 비즈니스 로직
- `BuildingController` - 건물 API 엔드포인트

## 📡 **API 엔드포인트**

### 1. **유저 건물 전체 조회**
```http
GET /api/users/{userId}/buildings/{buildingType}
Authorization: Bearer {token}
```

**경로 변수:**
- `userId`: 사용자 ID
- `buildingType`: `department`, `library`, `gym`, `cafe`

**응답:**
```json
{
  "building": {
    "id": 1,
    "buildingType": "DEPARTMENT",
    "currentFloor": 2,
    "exteriorUpgraded": false
  },
  "slots": [
    {
      "id": 1,
      "slotNumber": 1,
      "spaceType": "LECTURE",
      "currentLevel": 2,
      "isInstalled": true
    }
  ],
  "buildingConfig": {
    "floors": 5,
    "slotsPerFloor": 2,
    "exteriorUpgradeFloor": 3
  }
}
```

### 2. **특정 칸 조회**
```http
GET /api/users/{userId}/buildings/{buildingType}/slots/{slotNumber}
Authorization: Bearer {token}
```

**응답:**
```json
{
  "id": 1,
  "slotNumber": 1,
  "spaceType": "LECTURE",
  "currentLevel": 2,
  "isInstalled": true
}
```

### 3. **공간 설치**
```http
POST /api/users/{userId}/buildings/{buildingType}/slots/{slotNumber}/install
Authorization: Bearer {token}
Content-Type: application/json
```

**요청 바디:**
```json
{
  "spaceType": "LECTURE"
}
```

**응답:**
```json
{
  "id": 1,
  "slotNumber": 1,
  "spaceType": "LECTURE",
  "currentLevel": 1,
  "isInstalled": true
}
```

### 4. **공간 업그레이드**
```http
POST /api/users/{userId}/buildings/{buildingType}/slots/{slotNumber}/upgrade
Authorization: Bearer {token}
```

**응답:**
```json
{
  "id": 1,
  "slotNumber": 1,
  "spaceType": "LECTURE",
  "currentLevel": 2,
  "isInstalled": true
}
```

### 5. **외관 업그레이드**
```http
POST /api/users/{userId}/buildings/{buildingType}/exterior/upgrade
Authorization: Bearer {token}
```

**응답:**
```json
{
  "id": 1,
  "buildingType": "DEPARTMENT",
  "currentFloor": 3,
  "exteriorUpgraded": true
}
```

### 6. **공간/단계별 설정값 조회**
```http
GET /api/buildings/{buildingType}/spaces/config
```

**응답:**
```json
{
  "buildingType": "DEPARTMENT",
  "displayName": "학과 건물",
  "floors": 5,
  "slotsPerFloor": 2,
  "exteriorUpgradeFloor": 3,
  "spaces": {
    "LECTURE": {
      "displayName": "강의실",
      "basePrice": 500,
      "upgradePrice": 250,
      "maxLevel": 3
    }
  }
}
```

## 🎯 **사용 예시**

### **1. 학과 건물에 강의실 설치**
```bash
POST /api/users/user1/buildings/department/slots/1/install
{
  "spaceType": "LECTURE"
}
```
→ 학과&새도 코인 500개 차감, 1층 1번 칸에 강의실 설치

### **2. 강의실 업그레이드**
```bash
POST /api/users/user1/buildings/department/slots/1/upgrade
```
→ 학과&새도 코인 250개 차감, 강의실 레벨 2로 업그레이드

### **3. 1층 완성 시 자동 2층 확장**
1층의 모든 칸(1,2번)에 공간 설치 완료
→ 2층(3,4번) 자동으로 열림

### **4. 외관 업그레이드**
```bash
POST /api/users/user1/buildings/department/exterior/upgrade
```
→ 3층 달성 시 외관 업그레이드 가능 (무료)

## 🗄️ **데이터베이스 스키마**

### **user_buildings 테이블**
```sql
CREATE TABLE user_buildings (
    id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    building_type VARCHAR(20) NOT NULL,
    current_floor INTEGER NOT NULL DEFAULT 1,
    exterior_upgraded BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_user_building_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT uq_user_building_type UNIQUE (user_id, building_type)
);
```

### **user_building_slots 테이블**
```sql
CREATE TABLE user_building_slots (
    id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    building_type VARCHAR(20) NOT NULL,
    slot_number INTEGER NOT NULL,
    space_type VARCHAR(30),
    current_level INTEGER NOT NULL DEFAULT 0,
    is_installed BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_user_building_slot_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT uq_user_building_slot UNIQUE (user_id, building_type, slot_number)
);
```

## 🔧 **설정 및 실행**

1. **프로젝트 빌드**
```bash
./gradlew build
```

2. **애플리케이션 실행**
```bash
./gradlew bootRun
```

## 📝 **주요 특징**

- ✅ **자동 층 확장**: 한 층 완성 시 다음 층 자동 열림
- ✅ **코인 차감**: 공간 설치/업그레이드 시 자동으로 코인 차감
- ✅ **외관 업그레이드**: 조건 만족 시 무료로 외관 업그레이드
- ✅ **보안**: 사용자는 자신의 건물만 접근 가능
- ✅ **확장 가능**: 새로운 건물 타입과 공간 타입 쉽게 추가 가능

## 🚀 **향후 확장 계획**

- 건물별 특수 효과
- 공간 조합에 따른 보너스
- 친구와의 건물 비교
- 건물 랭킹 시스템
- 건물별 이벤트

이제 사용자들이 코인을 사용하여 건물을 건설하고 업그레이드할 수 있는 시스템이 완성되었습니다! 🎉
