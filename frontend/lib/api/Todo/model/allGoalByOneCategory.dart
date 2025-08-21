import 'package:frontend/api/Todo/model/category_model.dart';
import 'package:frontend/api/Todo/model/goal_model.dart';

// 화면에서 한 카테고리 블록 + 그 안의 목표들
class AllGoalsByOneCategory {
  final Category category;
  final List<Goal> goals;

  AllGoalsByOneCategory({required this.category, required this.goals});
}
