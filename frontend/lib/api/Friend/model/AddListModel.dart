class FriendRequest {
  final int id;
  final Map<String, dynamic> fromUser;
  final Map<String, dynamic> toUser;
  final String status;
  final String createdAt;

  FriendRequest({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      fromUser: json['fromUser'],
      toUser: json['toUser'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
