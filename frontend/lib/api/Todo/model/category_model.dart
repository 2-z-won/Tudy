class Category {
  final int id;
  final String name;
  final int color;
  final String categoryType;
  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.categoryType,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      categoryType: json['categoryType'],
    );
  }
}

class AddCategory {
  final String userId;
  final String name;
  final int color;
  final String categoryType;

  AddCategory({
    required this.userId,
    required this.name,
    required this.color,
    required this.categoryType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'color': color,
      'categoryType': categoryType,
    };
  }
}
