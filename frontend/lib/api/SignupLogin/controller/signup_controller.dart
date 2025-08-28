import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:frontend/constants/url.dart';
import 'package:frontend/api/SignupLogin/model/signup_model.dart';
import 'package:http/http.dart' as http;

class SignUpController extends GetxController {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final birthController = TextEditingController();
  var selectedCollege = ''.obs;
  final deptController = TextEditingController();

  var errorMessage = ''.obs;

  final specialCharReg = RegExp(r'[!@^#\$%&*(),.?":{}|<>]');
  final birthDateReg = RegExp(r'^\d{4}\.\d{2}\.\d{2}$'); // YYYY.MM.DD
  final passwordReg = RegExp(r'^.{8,}$'); // 8자 이상

  void signUp() async {
    errorMessage.value = '';

    final user = UserModel(
      email: emailController.text,
      id: idController.text,
      password: pwController.text,
      name: nameController.text,
      birth: birthController.text,
      college: selectedCollege.value,
      dept: deptController.text,
    );

    // 🧪 입력값 유효성 검사
    if (user.name.isEmpty ||
        user.id.isEmpty ||
        user.password.isEmpty ||
        user.birth.isEmpty ||
        selectedCollege.value.isEmpty ||
        user.dept.isEmpty) {
      errorMessage.value = "모든 항목을 입력해주세요.";
      return;
    }

    if (specialCharReg.hasMatch(user.name)) {
      errorMessage.value = "이름에는 특수문자를 사용할 수 없습니다.";
      return;
    }

    if (specialCharReg.hasMatch(user.id)) {
      errorMessage.value = "아이디에는 특수문자를 사용할 수 없습니다.";
      return;
    }

    if (!passwordReg.hasMatch(user.password)) {
      errorMessage.value = "비밀번호는 8자 이상이어야 합니다.";
      return;
    }

    if (!birthDateReg.hasMatch(user.birth)) {
      errorMessage.value = "생일 형식은 YYYY.MM.DD 형식으로 입력해주세요.";
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Urls.usersUrl}signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 200) {
        Get.offAllNamed('/login');
      } else {
        final data = json.decode(response.body);
        final message = data['message'] ?? '';

        if (message == "Email already exists") {
          errorMessage.value = "이미 사용 중인 이메일입니다.";
        } else if (message == "UserId already exists") {
          errorMessage.value = "이미 사용 중인 아이디입니다.";
        } else if (message == "Name already exists") {
          errorMessage.value = "이미 사용 중인 이름입니다.";
        } else {
          errorMessage.value = "회원가입에 실패했습니다.";
        }
      }
    } catch (e) {
      errorMessage.value = "서버와 연결할 수 없습니다.";
    }
  }
}
