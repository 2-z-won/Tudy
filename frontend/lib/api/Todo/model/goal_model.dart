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
  final String? friendNickname;
  final String proofType;
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
    this.friendNickname,
    required this.proofType,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      category: Category.fromJson(json['category']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      completed: json['completed'],
      isGroupGoal: json['isGroupGoal'],
      groupId: json['groupId'],
      isFriendGoal: json['isFriendGoal'],
      friendNickname: json['friendNickname'],
      proofType: json['proofType'],
    );
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
