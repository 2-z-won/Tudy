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
      id: json['id'],
      email: json['email'],
      name: json['name'],
      major: json['major'],
      college: json['college'],
      profileImage: json['profileImage'],
      coinBalance: json['coinBalance'],
    );
  }
}
