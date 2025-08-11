import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';
import 'package:frontend/utils/auth_util.dart';

class UserEditController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;

  String? userId;

  final name = ''.obs;
  final major = ''.obs;
  final college = ''.obs;
  final profileImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  // --- 개별 업데이트 ---
  Future<void> updateName(String newName) async {
    final uri = Uri.parse('${Urls.apiUrl}users/$userId/name');
    await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': newName}), // ✅ name 키
    );
    name.value = newName;
  }

  Future<void> updateMajor(String newMajor) async {
    final uri = Uri.parse('${Urls.apiUrl}users/$userId/major');
    await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'value': newMajor}), // ✅ value 키
    );
    major.value = newMajor;
  }

  Future<void> updateCollege(String newCollege) async {
    final uri = Uri.parse('${Urls.apiUrl}users/$userId/college');
    await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'value': newCollege}), // ✅ value 키
    );
    college.value = newCollege;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('${Urls.apiUrl}users/$userId/password');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('비밀번호 변경 실패');
    }
  }

  Future<void> updateProfileImageUrl(String url) async {
    final uri = Uri.parse('${Urls.apiUrl}users/$userId/profile-image');
    await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'imagePath': url}), // ✅ imagePath 키
    );
    profileImage.value = url;
  }

  /// 이미지 파일을 서버/스토리지에 업로드해서 URL을 받아오는 자리.
  /// 아직 업로드 API가 없으면 null을 리턴하고, 저장 시 스킵 처리.
  Future<String?> uploadProfileAndGetUrl(File file) async {
    // TODO: 여기에 업로드 구현(예: 서버 업로드 or Cloudinary)
    return null;
  }

  /// 저장 버튼에서 한 번에 호출
  Future<void> saveAll({
    required String newName,
    required String newMajor,
    required String newCollege,
    File? newProfileFile,
  }) async {
    isSaving.value = true;
    try {
      final futures = <Future>[];

      if (newName.trim() != name.value) futures.add(updateName(newName.trim()));
      if (newMajor.trim() != major.value)
        futures.add(updateMajor(newMajor.trim()));
      if (newCollege.trim() != college.value)
        futures.add(updateCollege(newCollege.trim()));

      if (newProfileFile != null) {
        final url = await uploadProfileAndGetUrl(newProfileFile);
        if (url != null && url.isNotEmpty) {
          futures.add(updateProfileImageUrl(url));
        }
      }

      await Future.wait(futures);
    } finally {
      isSaving.value = false;
    }
  }
}
