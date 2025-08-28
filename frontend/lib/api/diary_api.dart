import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/url.dart';

final Uri baseUrl = Uri.parse(Urls.apiUrl);

class DiaryDto {
  final String date;
  final String emoji;
  final String content;

  DiaryDto({required this.date, required this.emoji, required this.content});

  factory DiaryDto.fromJson(Map<String, dynamic> j) => DiaryDto(
    date: j['date'] ?? '',
    emoji: j['emoji'] ?? '',
    content: j['content'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'emoji': emoji,
    'content': content,
  };
}

class DiaryApi {
  static Map<String, String> _headers([String? token]) => {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  static Future<DiaryDto?> getDiary({
    required String date,
    String? token,
    String? userId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/diary',
    ).replace(queryParameters: {'date': date, 'userId': userId});

    print('🔍 일기 조회 API 호출: $uri');
    print('🔍 요청 헤더: ${_headers(token)}');
    print('🔍 사용자 ID: $userId');

    final res = await http.get(uri, headers: _headers(token));

    print('🟡 일기 조회 응답 상태: ${res.statusCode}');
    print('🟡 일기 조회 응답 내용: ${res.body}');

    if (res.statusCode == 200) {
      try {
        final jsonData = jsonDecode(res.body);
        print('✅ 일기 조회 성공 - 파싱된 데이터: $jsonData');
        return DiaryDto.fromJson(jsonData);
      } catch (e) {
        print('🔥 일기 조회 응답 파싱 실패: $e');
        return null;
      }
    } else {
      print('🔥 일기 조회 실패 - HTTP ${res.statusCode}: ${res.body}');
      return null;
    }
  }

  static Future<DiaryDto?> upsertDiary({
    required String date,
    required String emoji,
    required String content,
    String? token,
    String? userId,
  }) async {
    final uri = Uri.parse('$baseUrl/diary');
    
    final requestBody = {
      'userId': userId,
      'date': date, 
      'emoji': emoji, 
      'content': content
    };
    
    print('🔍 일기 저장 API 호출: $uri');
    print('🔍 요청 헤더: ${_headers(token)}');
    print('🔍 요청 본문: $requestBody');
    print('🔍 사용자 ID: $userId');

    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(requestBody),
    );

    print('🟡 일기 저장 응답 상태: ${res.statusCode}');
    print('🟡 일기 저장 응답 내용: ${res.body}');

    if (res.statusCode == 200) {
      try {
        final jsonData = jsonDecode(res.body);
        print('✅ 일기 저장 성공 - 파싱된 데이터: $jsonData');
        return DiaryDto.fromJson(jsonData);
      } catch (e) {
        print('🔥 일기 저장 응답 파싱 실패: $e');
        return null;
      }
    } else {
      print('🔥 일기 저장 실패 - HTTP ${res.statusCode}: ${res.body}');
      return null;
    }
  }
}
