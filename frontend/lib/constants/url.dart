import 'package:flutter/foundation.dart';

class BaseUrl {
  // 환경별 URL 설정
  static const String _developmentUrl = 'http://10.0.2.2:8080/api'; // Android Emulator용
  static const String _productionUrl = 'https://your-production-domain.com/api'; // 운영 서버용
  static const String _localUrl = 'http://localhost:8080/api'; // 로컬 개발용
  
  // 현재 환경에 따른 Base URL
  static String get baseUrl {
    if (kDebugMode) {
      // 디버그 모드에서는 개발 URL 사용
      return _developmentUrl;
    } else {
      // 릴리즈 모드에서는 운영 URL 사용
      return _productionUrl;
    }
  }
}

class Urls {
  static String get apiUrl => '${BaseUrl.baseUrl}/';
  
  // 자주 사용하는 엔드포인트들을 미리 정의
  static String get authUrl => '${apiUrl}auth/';
  static String get usersUrl => '${apiUrl}users/';
  static String get goalsUrl => '${apiUrl}goals/';
  static String get groupsUrl => '${apiUrl}groups/';
  static String get friendsUrl => '${apiUrl}friends/';
  static String get categoriesUrl => '${apiUrl}categories';
  static String get coinsUrl => '${apiUrl}coins/';
  static String get sessionsUrl => '${apiUrl}sessions';
  static String get diaryUrl => '${apiUrl}diary';
  static String get buildingsUrl => '${apiUrl}users/';
  
  // 도우미 메서드들
  static String userBuilding(String userId, String buildingType) => 
      '${usersUrl}$userId/buildings/$buildingType';
  
  static String goalsByDate(String userId, String date, {String? categoryName}) {
    String url = '${goalsUrl}by-date?userId=$userId&date=$date';
    if (categoryName != null) {
      url += '&categoryName=$categoryName';
    }
    return url;
  }
  
  static String groupPendingRequests(int groupId) =>
      '${groupsUrl}$groupId/pending-requests';
  
  static String groupApprove(int requestId, int groupId) =>
      '${groupsUrl}$requestId/approve?groupId=$groupId';
  
  static String groupReject(int requestId, int groupId) =>
      '${groupsUrl}$requestId/reject?groupId=$groupId';
  
  static String sessionDuration(int goalId) =>
      '${sessionsUrl}goal/$goalId/duration';
  
  // 환경 정보 출력 (디버깅용)
  static String get currentEnvironment => kDebugMode ? 'Development' : 'Production';
  static void printCurrentUrl() {
    if (kDebugMode) {
      print('🌐 Current API URL: ${BaseUrl.baseUrl}');
      print('🔧 Environment: $currentEnvironment');
    }
  }
}
