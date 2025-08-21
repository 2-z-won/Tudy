import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';

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
      final uri = Uri.parse('${Urls.apiUrl}goals/$goalId/proof-image');

      final req = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('proofImage', filePath));
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
