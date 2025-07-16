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

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.completed,
    required this.isGroupGoal,
    this.groupId,
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
    );
  }
}
