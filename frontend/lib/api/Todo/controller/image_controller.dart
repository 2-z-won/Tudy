import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';
import 'package:frontend/utils/auth_util.dart';

class GoalProofController extends GetxController {
  final isUploading = false.obs;
  final error = RxnString();

  /// 멀티파트로 이미지 업로드
  Future<bool> uploadProofImage({
    required int goalId,
    required String filePath,
  }) async {
    isUploading.value = true;
    error.value = null;

    try {
      // 인증 토큰 가져오기
      final token = await getTokenFromStorage();
      if (token == null) {
        error.value = '로그인 정보가 없습니다. 다시 로그인해주세요.';
        return false;
      }

      final uri = Uri.parse('${Urls.apiUrl}goals/$goalId/proof-image');

      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('image', filePath));
      
      print('🔍 이미지 업로드 요청: ${req.url}');
      print('🔍 Authorization 헤더: Bearer ${token.substring(0, 10)}...');
      print('🔍 파일 경로: $filePath');
      print('🔍 파일 확장자: ${filePath.split('.').last}');
      
      // 파일 크기 확인
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        print('🔍 파일 크기: ${fileSize} bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');
      }
      
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return true;
      } else {
        error.value = '업로드 실패 [${res.statusCode}] ${res.body}';
        return false;
      }
    } catch (e) {
      error.value = '업로드 에러: $e';
      return false;
    } finally {
      isUploading.value = false;
    }
  }
}
