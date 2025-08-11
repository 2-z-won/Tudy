// lib/api/Friend/model/friend_goal_model.dart
class FriendGoal {
  final String title;
  final bool completed;
  final String friendName;

  FriendGoal({
    required this.title,
    required this.completed,
    required this.friendName,
  });

  factory FriendGoal.fromJson(Map<String, dynamic> json) {
    return FriendGoal(
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
      friendName: json['friendName'] ?? '',
    );
  }
}
