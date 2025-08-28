import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';
import 'package:frontend/api/SignupLogin/model/verify_email_model.dart';

class EmailVerifyController extends GetxController {
  var errorMessage = ''.obs;
  var successMessage = ''.obs;
  var isVerified = false.obs;
  var emailSent = false.obs; // ✅ 이메일 전송 여부 상태 추가

  /// 이메일 인증번호 전송
  Future<void> sendCode(String email) async {
    if (email.isEmpty) {
      errorMessage.value = '이메일을 입력해주세요';
      return;
    }

    if (!email.endsWith('@pusan.ac.kr')) {
      errorMessage.value = '부산대 계정을 입력해주세요';
      return;
    }

    final url = Uri.parse('${Urls.authUrl}send-email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          emailSent.value = true; // ✅ 전송 상태 true로
          successMessage.value = '전송 완료 ! 입력하신 이메일로 인증번호를 보냈습니다';
        } else {
          emailSent.value = false;
          errorMessage.value = json['error'] ?? '인증번호 전송 실패';
        }
      } else {
        errorMessage.value = '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = '네트워크 오류: $e';
    }
  }

  /// 인증번호 검증
  Future<void> verifyEmail(String email, String code) async {
    if (!emailSent.value) {
      errorMessage.value = '이메일 인증을 먼저 진행해주세요';
      return;
    }

    if (code.isEmpty || code.length != 6 || int.tryParse(code) == null) {
      errorMessage.value = '6자리 숫자 인증번호를 입력해주세요';
      return;
    }

    final url = Uri.parse('${Urls.authUrl}verify-email');
    final requestData = EmailVerificationRequest(email: email, code: code);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        isVerified.value = json['success'] ?? false;

        if (isVerified.value) {
          errorMessage.value = '';
        } else {
          errorMessage.value = json['error'] ?? '인증번호가 틀렸습니다';
        }
      } else {
        errorMessage.value = '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = '네트워크 오류: $e';
    }
  }
}
