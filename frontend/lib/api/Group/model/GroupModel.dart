class Group {
  final int id;
  final String name;

  Group({required this.id, required this.name});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(id: json['id'], name: json['name']);
  }
}

class GroupGoal {
  final int id;
  final String title;
  final bool completed;
  final bool isGroupGoal;
  final int groupId;

  GroupGoal({
    required this.id,
    required this.title,
    required this.completed,
    required this.isGroupGoal,
    required this.groupId,
  });

  factory GroupGoal.fromJson(Map<String, dynamic> json) {
    return GroupGoal(
      id: json['id'],
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
      isGroupGoal: json['isGroupGoal'] ?? true,
      groupId: json['groupId'],
    );
  }
}
