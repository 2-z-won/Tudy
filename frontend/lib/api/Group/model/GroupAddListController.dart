class GroupRequest {
  final int id;
  final Map<String, dynamic> fromUser; // = user
  final Map<String, dynamic> group;
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
      id: json['id'],
      fromUser: json['user'],
      group: json['group'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
