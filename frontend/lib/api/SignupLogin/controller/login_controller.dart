import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:frontend/constants/url.dart';
import 'package:frontend/api/SignupLogin/model/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final idController = TextEditingController();
  final pwController = TextEditingController();

  var errorMessage = ''.obs;

  void login() async {
    errorMessage.value = '';

    // 입력값 검사
    if (idController.text.isEmpty || pwController.text.isEmpty) {
      errorMessage.value = "아이디와 비밀번호 모두 입력해주세요.";
      return;
    }

    final user = UserModel(id: idController.text, password: pwController.text);

    try {
      final response = await http.post(
        Uri.parse('${Urls.usersUrl}login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body);

        var accessToken = data['token'];
        await saveTokens(accessToken, idController.text);

        Get.offAllNamed('/main');
      } else {
        final data = json.decode(response.body);
        errorMessage.value = data['message'] ?? "아이디 또는 비밀번호가 틀렸습니다.";
      }
    } catch (e) {
      errorMessage.value = "서버와 연결할 수 없습니다.";
    }
  }

  Future<void> saveTokens(String accessToken, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('user_id', userId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');

    idController.clear();
    pwController.clear();

    // 로그인 페이지로 이동 (뒤로가기 방지)
    Get.offAllNamed('/login');
  }
}
