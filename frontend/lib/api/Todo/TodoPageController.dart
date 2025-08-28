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
  
  // CategoryController 인스턴스 (지연 초기화)
  CategoryController? _categoryController;

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
      // CategoryController 안전하게 가져오기
      _categoryController ??= Get.find<CategoryController>();
      print('🔧 CategoryController 준비 완료');
      
      final list = await _categoryController!.fetchCategories(uid);
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

  Future<void> loadGoalsForDate(DateTime date, {String? categoryName}) async {
    final uid = userId.value;
    if (uid == null) return;

    final mySeq = ++_goalReqSeq;
    isLoadingGoals.value = true;
    error.value = '';

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date.toLocal());
      print('🔍 목표 로딩 시작 - userId: $uid, date: $dateStr, category: $categoryName');

      // CategoryController 안전하게 가져오기
      _categoryController ??= Get.find<CategoryController>();
      
      // 날짜별 목표 조회 API 사용 (/api/goals/by-date)
      final List<Goal> goals = await _categoryController!.fetchGoalsByDate(
        userId: uid,
        date: dateStr,
        categoryName: categoryName,
      );
      
      print('🔍 받은 목표 개수: ${goals.length}');
      if (goals.isNotEmpty) {
        print('🔍 목표 예시: ${goals.first.title}');
      }

      // 1) 각 목표의 누적 시간을 조회하여 업데이트
      for (int i = 0; i < goals.length; i++) {
        if (goals[i].proofType == 'TIME') {
          try {
            final accumulatedSeconds = await GoalController.fetchGoalDurationSeconds(goals[i].id);
            if (accumulatedSeconds != null) {
              // Goal 객체를 새로 생성하여 totalDuration 업데이트
              goals[i] = Goal(
                id: goals[i].id,
                title: goals[i].title,
                category: goals[i].category,
                startDate: goals[i].startDate,
                endDate: goals[i].endDate,
                completed: goals[i].completed,
                isGroupGoal: goals[i].isGroupGoal,
                groupId: goals[i].groupId,
                isFriendGoal: goals[i].isFriendGoal,
                friendName: goals[i].friendName,
                proofType: goals[i].proofType,
                targetTime: goals[i].targetTime,
                proofImage: goals[i].proofImage,
                totalDuration: accumulatedSeconds,
              );
            }
          } catch (e) {
            print('🔥 목표 ${goals[i].id} 누적 시간 조회 실패: $e');
            // 실패해도 계속 진행
          }
        }
      }

      // 2) 카테고리 id 기준으로 그룹화
      final grouped = groupBy<Goal, int>(goals, (g) => g.category.id);

      // 3) 화면 모델로 변환
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
        print('🔍 목표 로딩 완료 - ${items.length}개 카테고리, ${goals.length}개 목표');
      }
    } catch (e) {
      print('🔥 목표 로딩 실패: $e');
      if (mySeq == _goalReqSeq) {
        error.value = '목표 불러오기 실패: $e';
      }
    } finally {
      if (mySeq == _goalReqSeq) {
        isLoadingGoals.value = false;
      }
    }
  }

  // 카테고리별 목표 필터링
  Future<void> loadGoalsByCategory(String? categoryName) async {
    await loadGoalsForDate(selectedDate.value, categoryName: categoryName);
  }
}
