class Friend {
  final int id;
  final String email;
  final String name;
  final String major;
  final String college;
  final String profileImage;
  final int coinBalance;

  Friend({
    required this.id,
    required this.email,
    required this.name,
    required this.major,
    required this.college,
    required this.profileImage,
    required this.coinBalance,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      major: json['major'] ?? '',
      college: json['college'] ?? '',
      profileImage: json['profileImage'] ?? '',
      coinBalance: json['coinBalance'] ?? 0,
    );
  }
}

// api/Friend/model/friend_goal_model.dart
class FriendGoal {
  final int id;
  final String title;
  final bool completed;
  final bool isFriendGoal;
  final String friendName;

  FriendGoal({
    required this.id,
    required this.title,
    required this.completed,
    required this.isFriendGoal,
    required this.friendName,
  });

  factory FriendGoal.fromJson(Map<String, dynamic> json) {
    return FriendGoal(
      id: json['id'],
      title: json['title'],
      completed: json['completed'] ?? false,
      isFriendGoal: json['isFriendGoal'] ?? true,
      friendName: json['friendName'] ?? '',
    );
  }
}

