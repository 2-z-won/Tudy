class User {
  final int id;
  final String email;
  final String userId;
  final String name;
  final String? birth;
  final String? major;
  final String? college;
  final String? profileImage;
  final int coinBalance;
  final String? lastStudyDate;
  final bool dirty;

  User({
    required this.id,
    required this.email,
    required this.userId,
    required this.name,
    this.birth,
    this.major,
    this.college,
    this.profileImage,
    required this.coinBalance,
    this.lastStudyDate,
    required this.dirty,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] is int) ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      email: json['email']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      birth: json['birth']?.toString(),
      major: json['major']?.toString(),
      college: json['college']?.toString(),
      profileImage: json['profileImage']?.toString(),
      coinBalance: (json['coinBalance'] is int) ? json['coinBalance'] : int.tryParse(json['coinBalance']?.toString() ?? '0') ?? 0,
      lastStudyDate: json['lastStudyDate']?.toString(),
      dirty: json['dirty'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'userId': userId,
      'name': name,
      'birth': birth,
      'major': major,
      'college': college,
      'profileImage': profileImage,
      'coinBalance': coinBalance,
      'lastStudyDate': lastStudyDate,
      'dirty': dirty,
    };
  }
}
