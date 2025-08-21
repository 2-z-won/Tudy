class Category {
  final int id;
  final String name;
  final int color;
  final String? categoryType;
  final String icon;
  Category({
    required this.id,
    required this.name,
    required this.color,
    this.categoryType,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      categoryType: json['categoryType'] ?? '',
      icon: json['icon'],
    );
  }
}

class AddCategory {
  final String userId;
  final String name;
  final int color;
  final String categoryType;
  final String icon;

  AddCategory({
    required this.userId,
    required this.name,
    required this.color,
    required this.categoryType,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'color': color,
      'categoryType': categoryType,
      'icon': icon,
    };
  }
}
