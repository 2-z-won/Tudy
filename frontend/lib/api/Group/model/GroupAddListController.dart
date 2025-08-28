class GroupRequest {
  final int id;
  final Map<String, dynamic>? fromUser; // = user (nullable)
  final Map<String, dynamic>? group; // (nullable)
  final String status;
  final String createdAt;

  GroupRequest({
    required this.id,
    required this.fromUser,
    required this.group,
    required this.status,
    required this.createdAt,
  });

  factory GroupRequest.fromJson(Map<String, dynamic> json) {
    return GroupRequest(
      id: json['id'] as int,
      fromUser: json['user'] as Map<String, dynamic>?,
      group: json['group'] as Map<String, dynamic>?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
