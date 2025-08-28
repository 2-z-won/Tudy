import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:frontend/constants/url.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:frontend/api/SignupLogin/controller/UserController.dart';
import 'package:frontend/api/SignupLogin/model/UserModel.dart';

class MyPageController extends GetxController {
  // 유저
  final userId = ''.obs; // String 타입으로 변경 (user_id 컬럼 값 저장)
  final userEmail = ''.obs;

  // 프로필
  final name = ''.obs;
  final college = ''.obs;
  final department = ''.obs;
  final profileImage = ''.obs;
  final birth = ''.obs;
  final password = ''.obs;

  // 지표
  final coinBalance = 0.obs;
  final friendCount = 0.obs;
  final todayGoalCount = 0.obs;
  final groupCount = 0.obs;

  final isLoading = false.obs;
  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    _userId = await getUserIdFromStorage();
    if (_userId == null) {
      isLoading.value = false;
      return;
    }

    print('🔍 마이페이지 데이터 로딩 시작 - 저장된 userId: $_userId');
    print('🔍 이 값은 getUserIdFromStorage()에서 가져온 값입니다');
    
    // 모든 데이터를 병렬로 로드
    await Future.wait([
      _fetchUser(),
      _fetchTodayGoalCount(),
      _fetchFriendCount(),
      _fetchGroupCount(),
    ]);

    print('✅ 마이페이지 데이터 로딩 완료');
    print('📊 최종 통계: 목표 ${todayGoalCount.value}개, 친구 ${friendCount.value}명, 그룹 ${groupCount.value}개');
    print('🔍 최종 사용자 ID: $_userId');
    print('🔍 이 값은 데이터베이스의 user_id 컬럼 값입니다 (test7, test8 등)');
    
    isLoading.value = false;
  }

  Future<void> _fetchUser() async {
    try {
      final user = await UserController.getUserInfo(_userId!);
      if (user != null) {
        // user_id 컬럼의 값을 userId 변수에 설정 (primary key가 아닌 user_id 컬럼)
        userId.value = user.userId;
        _userId = user.userId;
        userEmail.value = user.email;
        birth.value = user.birth ?? '';
        name.value = user.name;
        college.value = user.college ?? '';
        department.value = user.major ?? '';
        profileImage.value = user.profileImage ?? '';

        coinBalance.value = user.coinBalance;
        
        print('🔍 사용자 정보 설정 완료 - userId: ${user.userId}, name: ${user.name}');
        print('🔍 데이터베이스 user_id 컬럼 값: ${user.userId}');
        print('🔍 데이터베이스 primary key 값: ${user.id}');
        
        // 친구 수와 그룹 수는 별도로 가져오기
        await _fetchFriendCount();
        await _fetchGroupCount();
      }
    } catch (e) {
      print('🔥 사용자 정보 조회 중 에러: $e');
    }
  }

  Future<void> _fetchTodayGoalCount() async {
    if (_userId == null) return;
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final uri = Uri.parse(
        '${Urls.apiUrl}goals/by-date',
      ).replace(queryParameters: {'userId': _userId!, 'date': today});
      
      final token = await getTokenFromStorage();
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('🔍 오늘 목표 API 호출: $uri');
      print('🟡 오늘 목표 응답 상태: ${res.statusCode}');
      print('🟡 오늘 목표 응답 내용: ${res.body}');
      
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        todayGoalCount.value = list.length;
        print('✅ 오늘 목표 개수: ${list.length}개');
      } else {
        todayGoalCount.value = 0;
        print('🔥 오늘 목표 API 실패: ${res.statusCode}');
      }
    } catch (e) {
      print('🔥 오늘 목표 조회 중 에러: $e');
      todayGoalCount.value = 0;
    }
  }

  Future<void> _fetchFriendCount() async {
    if (_userId == null) return;
    try {
      final uri = Uri.parse('${Urls.apiUrl}friends/$_userId');
      final token = await getTokenFromStorage();
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final friends = data['friends'] as List?;
        friendCount.value = friends?.length ?? 0;
      } else {
        friendCount.value = 0;
      }
    } catch (e) {
      print('🔥 친구 수 조회 중 에러: $e');
      friendCount.value = 0;
    }
  }

  Future<void> _fetchGroupCount() async {
    if (_userId == null) return;
    try {
      final token = await getTokenFromStorage();
      final uri = Uri.parse('${Urls.apiUrl}groups/user');
      
      print('🔍 그룹 수 API 호출: $uri');
      
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('🟡 그룹 수 응답 상태: ${res.statusCode}');
      print('🟡 그룹 수 응답 내용: ${res.body}');
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final groups = data['groups'] as List?;
        groupCount.value = groups?.length ?? 0;
        print('✅ 그룹 수: ${groupCount.value}개');
      } else {
        groupCount.value = 0;
        print('🔥 그룹 수 API 실패: ${res.statusCode}');
      }
    } catch (e) {
      print('🔥 그룹 수 조회 중 에러: $e');
      groupCount.value = 0;
    }
  }
  
  // 수동 새로고침 메서드
  Future<void> refreshData() async {
    print('🔄 마이페이지 데이터 수동 새로고침 시작');
    await _loadAll();
  }
}
