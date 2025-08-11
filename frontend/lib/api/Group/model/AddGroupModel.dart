class AddGroup {
  final String name;
  final String password;
  final String ownerId;

  AddGroup({required this.name, required this.password, required this.ownerId});

  Map<String, dynamic> toJson() {
    return {'name': name, 'password': password, 'ownerId': ownerId};
  }
}

class GroupResponse {
  final int id;
  final String name;
  final String password;

  GroupResponse({required this.id, required this.name, required this.password});

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    return GroupResponse(
      id: json['id'],
      name: json['name'],
      password: json['password'],
    );
  }
}
