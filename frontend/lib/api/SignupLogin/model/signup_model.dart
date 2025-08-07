// models/user_model.dart
class UserModel {
  final String email;
  final String id;
  final String password;
  final String name;
  final String birth;
  final String college;
  final String dept;

  UserModel({
    required this.email,
    required this.id,
    required this.password,
    required this.name,
    required this.birth,
    required this.college,
    required this.dept,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "userId": id,
      "password": password,
      "name": name,
      "birth": birth,
      "college": college,
      "dept": dept,
    };
  }
}
