import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';

class EditMypageController extends GetxController {
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  final lastUserJson = Rxn<Map<String, dynamic>>();
  final birth = ''.obs;
  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};

  //이름 변경
  Future<bool> updateName({
    required String userId,
    required String name,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';
    final uri = Uri.parse('${Urls.apiUrl}users/$userId/name');
    final res = await http.put(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'name': name}),
    );
    isSaving.value = false;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return true;
    } else {
      errorMessage.value = '이름 변경 실패 [${res.statusCode}] ${res.body}';
      return false;
    }
  }

  //단과대 변경
  Future<bool> updateCollege({
    required String userId,
    required String college,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';
    final uri = Uri.parse('${Urls.apiUrl}users/$userId/college');
    final res = await http.put(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'value': college}),
    );
    isSaving.value = false;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isNotEmpty) {
        lastUserJson.value = jsonDecode(res.body) as Map<String, dynamic>;
      }
      return true;
    } else {
      errorMessage.value = '단과대 변경 실패 [${res.statusCode}] ${res.body}';
      return false;
    }
  }

  //학과/학부(전공) 변경
  Future<bool> updateMajor({
    required String userId,
    required String major,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';
    final uri = Uri.parse('${Urls.apiUrl}users/$userId/major');
    final res = await http.put(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'value': major}),
    );
    isSaving.value = false;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isNotEmpty) {
        lastUserJson.value = jsonDecode(res.body) as Map<String, dynamic>;
      }
      return true;
    } else {
      errorMessage.value = '전공 변경 실패 [${res.statusCode}] ${res.body}';
      return false;
    }
  }

  ///비밀번호 변경
  Future<bool> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';
    final uri = Uri.parse('${Urls.apiUrl}users/$userId/password');
    final res = await http.put(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    isSaving.value = false;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return true;
    } else {
      errorMessage.value = '비밀번호 변경 실패 [${res.statusCode}] ${res.body}';
      return false;
    }
  }

  //프로필 이미지 변경
  Future<bool> updateProfileImage({
    required String userId,
    required String imageUrl,
  }) async {
    isSaving.value = true;
    errorMessage.value = '';
    final uri = Uri.parse('${Urls.apiUrl}users/$userId/profile-image');
    final res = await http.put(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'imagePath': imageUrl}),
    );
    isSaving.value = false;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return true;
    } else {
      errorMessage.value = '프로필 이미지 변경 실패 [${res.statusCode}] ${res.body}';
      return false;
    }
  }

  Future<bool> updateBirth({
    required String userId,
    required String birthDate,
    String bodyKey = 'value',
  }) async {
    isSaving.value = true;
    errorMessage.value = '';

    final uri = Uri.parse('${Urls.apiUrl}users/$userId/birth');
    final res = await http.put(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({bodyKey: birthDate}),
    );

    isSaving.value = false;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      birth.value = birthDate;
      return true;
    } else {
      errorMessage.value = '생일 변경 실패 [${res.statusCode}] ${res.body}';
      return false;
    }
  }
}
