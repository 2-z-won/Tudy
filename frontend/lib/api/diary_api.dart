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
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/diary',
    ).replace(queryParameters: {'date': date});

    final res = await http.get(uri, headers: _headers(token));

    if (res.statusCode == 200) {
      return DiaryDto.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<DiaryDto?> upsertDiary({
    required String date,
    required String emoji,
    required String content,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/api/diary');

    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'date': date, 'emoji': emoji, 'content': content}),
    );

    if (res.statusCode == 200) {
      return DiaryDto.fromJson(jsonDecode(res.body));
    }
    return null;
  }
}
