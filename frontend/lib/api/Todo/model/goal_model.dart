import 'package:frontend/api/Todo/model/category_model.dart';

// goal_model.dart
import 'package:frontend/api/Todo/model/category_model.dart';

class Goal {
  final int id;
  final String title;
  final Category category;

  final DateTime startDate;
  final DateTime endDate;

  final bool completed;

  final bool isGroupGoal;
  final int? groupId;
  final bool isFriendGoal;
  final String? friendName; // ← friendName/friendNickname 모두 처리

  final String proofType; // 'TIME' | 'IMAGE'
  final int? targetTime; // 초

  // ✅ 백엔드가 추가로 주는 필드
  final String? proofImage; // 이미지 인증 파일 경로
  final int? totalDuration; // 누적 시간(초) — TIME일 때

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.completed,
    required this.isGroupGoal,
    this.groupId,
    required this.isFriendGoal,
    this.friendName,
    required this.proofType,
    this.targetTime,
    this.proofImage,
    this.totalDuration,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as int,
      title: (json['title'] ?? '').toString(),
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      completed: json['completed'] as bool,
      isGroupGoal: json['isGroupGoal'] as bool,
      groupId: json['groupId'] as int?,
      isFriendGoal: json['isFriendGoal'] as bool,
      friendName: (json['friendName'] ?? json['friendNickname']) as String?,
      proofType: json['proofType'] as String,
      targetTime: json['targetTime'] as int?,
      proofImage: json['proofImage'] as String?,
      totalDuration: json['totalDuration'] as int?,
    );
  }

  /// 유틸: 시간 목표 진행률 (0.0 ~ 1.0)
  double get timeProgressRatio {
    if (proofType != 'TIME') return completed ? 1.0 : 0.0;
    final t = targetTime ?? 0;
    if (t <= 0) return completed ? 1.0 : 0.0;
    final total = (totalDuration ?? 0).toDouble();
    return (total / t).clamp(0.0, 1.0);
    // completed면 1.0로 올리고 싶으면:
    // return completed ? 1.0 : (total / t).clamp(0.0, 1.0);
  }
}

class AddGoal {
  final String userId;
  final String title;
  final String categoryName;
  final String startDate;
  final String endDate;
  final bool isGroupGoal;
  final int? groupId;
  final bool isFriendGoal;
  final String? friendName;
  final String proofType;
  final int? targetTime; // ✅ 타입 변경

  AddGoal({
    required this.userId,
    required this.title,
    required this.categoryName,
    required this.startDate,
    required this.endDate,
    required this.isGroupGoal,
    this.groupId,
    required this.isFriendGoal,
    this.friendName,
    required this.proofType,
    this.targetTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'categoryName': categoryName,
      'startDate': startDate,
      'endDate': endDate,
      'isGroupGoal': isGroupGoal,
      'groupId': groupId,
      'isFriendGoal': isFriendGoal,
      'friendName': friendName,
      'proofType': proofType,
      'targetTime': targetTime,
    };
  }
}
