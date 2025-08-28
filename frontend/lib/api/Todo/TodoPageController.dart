// TodoPageController.dart
import 'package:frontend/api/Todo/model/allGoalByOneCategory.dart';
import 'package:frontend/api/Todo/controller/category_controller.dart';
import 'package:frontend/api/Todo/controller/goal_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/api/Todo/model/category_model.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:frontend/api/Todo/model/goal_model.dart';

class TodoPageController extends GetxController {
  final userId = RxnString();
  final selectedDate = DateTime.now().obs;
  final categories = <Category>[].obs;

  final allGoalsByAllCategory = <AllGoalsByOneCategory>[].obs;

  final isLoadingCategories = false.obs;
  final isLoadingGoals = false.obs;
  final error = ''.obs;

  int _goalReqSeq = 0;

  Future<void> init(String uid) async {
    print('🟢 ctrl.init start uid=$uid');
    userId.value = uid;
    await loadCategories();
    await loadGoalsForDate(selectedDate.value);
    print('🟢 ctrl.init done');
  }

  Future<void> changeDate(DateTime d) async {
    selectedDate.value = d;
    await loadGoalsForDate(d);
  }

  Future<void> loadCategories() async {
    final uid = userId.value;
    print('👀 loadCategories: uid=$uid');
    if (uid == null) return;
    isLoadingCategories.value = true;
    error.value = '';
    try {
      final list = await CategoryController.fetchCategories(uid);
      print('📥 fetchCategories 결과: ${list.map((c) => c.name).toList()}');
      categories.assignAll(list);
      print('✅ assignAll 후: ${categories.map((c) => c.name).toList()}');
    } catch (e) {
      error.value = '카테고리 불러오기 실패: $e';
      print('🔥 fetchCategories 실패: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> loadGoalsForDate(DateTime date) async {
    final uid = userId.value;
    if (uid == null) return;

    final mySeq = ++_goalReqSeq;
    isLoadingGoals.value = true;
    error.value = '';

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date.toLocal());

      // ⚠️ 실제 호출 위치에 맞춰서 사용 (CategoryController or GoalController)
      final List<Goal> goals = await CategoryController.fetchGoalsByDate(
        userId: uid,
        date: dateStr,
      );

      // 1) 카테고리 id 기준으로 그룹화
      final grouped = groupBy<Goal, int>(goals, (g) => g.category.id);

      // 2) 화면 모델로 변환
      final items = grouped.entries.map((entry) {
        final List<Goal> groupGoals = entry.value;
        // 동일 id 그룹이므로 첫 번째 요소에서 카테고리를 꺼내면 됨
        final Category cat = groupGoals.first.category;
        return AllGoalsByOneCategory(category: cat, goals: groupGoals);
      }).toList();

      // (선택) 정렬이 필요하면 여기서 정렬
      items.sort((a, b) => a.category.name.compareTo(b.category.name));

      if (mySeq == _goalReqSeq) {
        allGoalsByAllCategory.assignAll(items);
      }
    } catch (e) {
      if (mySeq == _goalReqSeq) {
        error.value = '목표 불러오기 실패: $e';
      }
    } finally {
      if (mySeq == _goalReqSeq) {
        isLoadingGoals.value = false;
      }
    }
  }
}
