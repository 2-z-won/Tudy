import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:frontend/constants/url.dart';
import 'package:frontend/utils/auth_util.dart';

class MyPageController extends GetxController {
  // 유저
  final userId = RxnInt();
  final userEmail = ''.obs;

  // 프로필
  final name = ''.obs;
  final college = ''.obs;
  final department = ''.obs; // = major
  final profileImage = ''.obs;

  // 지표
  final coinBalance = 0.obs;
  final friendCount = 0.obs;
  final todayGoalCount = 0.obs;
  final groupCount = 0.obs; // 아직 API 없으면 0 유지

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

    await Future.wait([
      _fetchUser(), // /api/users/{userId}
      _fetchTodayGoalCount(), // 기존 by-date 사용
      //_fetchGroupCount(),     // 있으면 붙이고, 없으면 0
    ]);

    isLoading.value = false;
  }

  Future<void> _fetchUser() async {
    try {
      final uri = Uri.parse('${Urls.apiUrl}users/$_userId');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        userId.value = (data['id'] as num?)?.toInt();
        userEmail.value = (data['email'] as String?) ?? '';

        name.value = data['name'] ?? '';
        college.value = data['college'] ?? '';
        department.value = data['major'] ?? '';
        profileImage.value = data['profileImage'] ?? '';

        coinBalance.value = (data['coinBalance'] ?? 0) as int;
        friendCount.value = (data['friendCount'] ?? 0) as int;
      }
    } catch (_) {
      /* 무시 */
    }
  }

  Future<void> _fetchTodayGoalCount() async {
    if (_userId == null) return;
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final uri = Uri.parse(
        '${Urls.apiUrl}goals/by-date',
      ).replace(queryParameters: {'userId': _userId!, 'date': today});
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        todayGoalCount.value = list.length;
      } else {
        todayGoalCount.value = 0;
      }
    } catch (_) {
      todayGoalCount.value = 0;
    }
  }

  // Future<void> _fetchGroupCount() async {
  //   // TODO: 그룹 API 나오면 연결
  //   groupCount.value = 0;
  // }
}
