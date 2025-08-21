import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/Friend/controller/FriendListController.dart';
import 'package:frontend/api/Group/controller/GroupController.dart';
import 'package:frontend/api/Todo/controller/goal_controller.dart';
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/components/Todo/TodoColor.dart';
import 'package:frontend/components/Todo/TodoList/SectionCard.dart';
import 'package:frontend/components/Todo/TodoList/component/TodoList_component.dart';
import 'package:frontend/components/Todo/TodoList/component/pop_transitions.dart';
import 'package:frontend/components/check.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:intl/intl.dart';
import 'dart:ui' show lerpDouble;
import 'package:get/get.dart';

class AddTodoForm extends StatefulWidget {
  final String categoryName;
  final Color categoryColor;
  final VoidCallback? onExit;

  /// 제출 시 선택값 전달
  final void Function({required String title, required Set<String> types})
  onSubmit;

  const AddTodoForm({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.onSubmit,
    this.onExit,
  });

  @override
  State<AddTodoForm> createState() => _AddTodoFormState();
}

class _AddTodoFormState extends State<AddTodoForm>
    with TickerProviderStateMixin {
  final TextEditingController _title = TextEditingController();

  final GoalController _goalController = GoalController();
  final MyGroupController _groupController = Get.put(MyGroupController());
  final FriendListController _friendController =
      Get.isRegistered<FriendListController>()
      ? Get.find<FriendListController>()
      : Get.put(FriendListController());

  String? _userId;

  bool isTimeSelected = true;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Duration selectedDuration = const Duration(hours: 0, minutes: 0);

  int? selectedGroupId;
  String? selectedFriendName;
  bool get isGroupGoal => selectedGroupId != null;
  bool get isFriendGoal => selectedFriendName != null;

  bool get _isFormValid {
    final hasTitle = _title.text.trim().isNotEmpty;
    final okDuration = !isTimeSelected || selectedDuration.inSeconds > 0;
    return hasTitle && okDuration;
  }

  late final AnimationController _inCtrl;
  late final Animation<double> _aHeader,
      _aTypeCategory,
      _aGoal,
      _aDuration,
      _aVerify,
      _aStudyWith,
      _aSubmit;

  void showCupertinoDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required void Function(DateTime) onDatePicked,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // ⛔ BottomSheet 테두리 제거
      builder: (_) {
        return Container(
          color: Colors.white, // ✅ 전체 배경 흰색
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: initialDate,
            onDateTimeChanged: onDatePicked,
            use24hFormat: true,
            dateOrder: DatePickerDateOrder.ymd,
          ),
        );
      },
    );
  }

  void showCupertinoDurationPicker({
    required BuildContext context,
    required Duration initialDuration,
    required void Function(Duration) onDurationPicked,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) {
        return SizedBox(
          height: 250,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: initialDuration,
            onTimerDurationChanged: onDurationPicked,
          ),
        );
      },
    );
  }

  void _selectGroup(int id) {
    setState(() {
      // 같은 그룹 다시 누르면 해제, 아니면 선택
      selectedGroupId = (selectedGroupId == id) ? null : id;
      // 그룹을 선택했으면 친구 선택은 해제
      selectedFriendName = null;
    });
  }

  void _selectFriend(String name) {
    setState(() {
      // 같은 친구 다시 누르면 해제, 아니면 선택
      selectedFriendName = (selectedFriendName == name) ? null : name;
      // 친구를 선택했으면 그룹 선택은 해제
      selectedGroupId = null;
    });
  }

  @override
  void initState() {
    super.initState();

    _initUserAndLists();

    _title.addListener(() => setState(() {}));

    _inCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 순서: 헤더 → 상단(카테고리/목표) → 기간 → 인증(Verification) → 스터디위드 → 완료버튼
    _aHeader = CurvedAnimation(
      parent: _inCtrl,
      curve: const Interval(0.00, 0.22, curve: Curves.easeOut),
    );
    _aTypeCategory = CurvedAnimation(
      // 왼쪽 박스가 먼저
      parent: _inCtrl,
      curve: const Interval(0.10, 0.38, curve: Curves.easeOut),
    );

    _aGoal = CurvedAnimation(
      // 오른쪽 SectionCard가 뒤이어
      parent: _inCtrl,
      curve: const Interval(0.18, 0.48, curve: Curves.easeOut),
    );
    _aDuration = CurvedAnimation(
      parent: _inCtrl,
      curve: const Interval(0.26, 0.56, curve: Curves.easeOut),
    );
    _aVerify = CurvedAnimation(
      parent: _inCtrl,
      curve: const Interval(0.42, 0.72, curve: Curves.easeOut),
    );
    _aStudyWith = CurvedAnimation(
      parent: _inCtrl,
      curve: const Interval(0.52, 0.82, curve: Curves.easeOut),
    );
    _aSubmit = CurvedAnimation(
      parent: _inCtrl,
      curve: const Interval(0.68, 1.00, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inCtrl.forward();
    });
  }

  Future<void> _submit() async {
    if (_userId == null) {
      _goalController.errorMessage.value = "로그인 정보가 없습니다. 다시 로그인해주세요.";
      return;
    }
    if (_title.text.trim().isEmpty) {
      _goalController.errorMessage.value = "목표 제목을 입력해주세요.";
      return;
    }

    final formatter = DateFormat('yyyy-MM-dd');
    final dto = AddGoal(
      userId: _userId!, // String
      title: _title.text.trim(),
      categoryName: widget.categoryName, // ✅ 부모에서 받은 카테고리 이름
      startDate: formatter.format(startDate),
      endDate: formatter.format(endDate),
      isGroupGoal: isGroupGoal,
      groupId: selectedGroupId,
      isFriendGoal: isFriendGoal,
      friendName: selectedFriendName,
      proofType: isTimeSelected ? "TIME" : "IMAGE",
      targetTime: isTimeSelected ? selectedDuration.inSeconds : null,
    );

    await _goalController.addGoal(dto);

    // 에러 없으면 닫기 + 부모 콜백 호출(선택)
    if (!_goalController.errorMessage.value.isNotEmpty) {
      widget.onExit?.call();
      // 필요하면 기존 onSubmit도 호출해서 상위 상태 갱신 트리거
      widget.onSubmit(
        title: dto.title,
        types: {isTimeSelected ? 'time' : 'photo'},
      );
    }
  }

  Future<void> _initUserAndLists() async {
    final uid = await getUserIdFromStorage();
    setState(() => _userId = uid);

    if (uid != null) {
      await _groupController.fetchMyGroups(uid);
      await _friendController.fetchFriendsAndGoals(uid);
    }
  }

  @override
  void dispose() {
    _inCtrl.dispose();
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 폼만 그리므로 배경색은 부모가 정합니다. (필요하면 최상단 Container color로 지정)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 21),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Add Todo',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "GmarketSans",
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: widget.onExit,
                child: Icon(Icons.exit_to_app),
              ),
            ],
          ),
        ).popIn(_aHeader),
        const SizedBox(height: 5),

        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 11),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 85,
                      child: Container(
                        height: 85,
                        padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
                        decoration: BoxDecoration(
                          color: widget.categoryColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [dropShadow],
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,

                              child: Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: SizedBox(
                                  height: 21,
                                  child: Text(
                                    widget.categoryName,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment
                                    .bottomRight, // ← 여기만 바뀜 (Center → Align)
                                child: Text(
                                  "Category",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "GmarketSans",
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).popIn(_aTypeCategory),
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      flex: 249,
                      child: SectionCard(
                        height: 85,
                        title: '🔥Goal🔥',
                        contentAlignment: Alignment.centerLeft,
                        child: TextField(
                          controller: _title,
                          keyboardType: TextInputType.multiline, // ✅ 줄바꿈 허용
                          maxLines: null, // ✅ 무제한 줄바꿈 가능
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF303030),
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: '오늘의 목표를 작성해주세요',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA9A9A9),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ).popIn(_aGoal),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                SectionCard(
                  height: 73,
                  title: '📆 Duration',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showCupertinoDatePicker(
                            context: context,
                            initialDate: startDate,
                            onDatePicked: (picked) {
                              setState(() {
                                startDate = picked;
                              });
                            },
                          );
                        },
                        child: Text(
                          DateFormat('yyyy.MM.dd').format(startDate),
                          style: TextStyle(
                            fontFamily: "GmarketSans",
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        "  ~  ",
                        style: TextStyle(
                          fontFamily: "GmarketSans",
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showCupertinoDatePicker(
                            context: context,
                            initialDate: endDate,
                            onDatePicked: (picked) {
                              setState(() {
                                endDate = picked;
                              });
                            },
                          );
                        },
                        child: Text(
                          DateFormat('yyyy.MM.dd').format(endDate),
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "GmarketSans",
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).popIn(_aDuration),
                const SizedBox(height: 7),

                Obx(() {
                  final hasGroups = _groupController.myGroups.isNotEmpty;
                  final hasFriends = _friendController.friendList.isNotEmpty;
                  final showStudyWith = hasGroups || hasFriends;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 왼쪽: Verification 카드는 항상 표시
                      Expanded(
                        flex: 220,
                        child: SectionCard(
                          height: 138,
                          title: '⏱️ Verification',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 시간 측정
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isTimeSelected = true;
                                  });
                                },
                                child: Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    isTimeSelected
                                        ? const CheckIcon()
                                        : const NoCheckIcon(),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Timer ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "GmarketSans",
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Text(
                                      '(목표 시간 설정)',
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ],
                                ),
                              ),

                              // 타이머 텍스트
                              AnimatedSize(
                                duration: Duration(microseconds: 800),
                                curve: Curves.easeInOut,
                                child: isTimeSelected
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          top: 12,
                                          bottom: 5,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            showCupertinoDurationPicker(
                                              context: context,
                                              initialDuration: selectedDuration,
                                              onDurationPicked: (duration) {
                                                setState(() {
                                                  selectedDuration = duration;
                                                });
                                              },
                                            );
                                          },
                                          child: Center(
                                            child: Text(
                                              '${selectedDuration.inHours.toString().padLeft(2, '0')}h  :  ${(selectedDuration.inMinutes % 60).toString().padLeft(2, '0')}m',
                                              style: const TextStyle(
                                                fontFamily: "GmarketSans",
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                                fontSize: 15,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ),
                              SizedBox(height: 8),

                              // 사진 인증 체크박스
                              // 사진 인증
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isTimeSelected = false;
                                  });
                                },
                                child: Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    !isTimeSelected
                                        ? const CheckIcon()
                                        : const NoCheckIcon(),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Photo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "GmarketSans",
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).popIn(_aVerify),
                      ),

                      // 오른쪽: Study With는 데이터 있을 때만 표시
                      if (showStudyWith) ...[
                        const SizedBox(width: 7),
                        Expanded(
                          flex: 129,
                          child: SectionCard(
                            height: 138,
                            title: '👤 Study With',
                            contentAlignment: Alignment.centerLeft,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (hasGroups) ...[
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 8,
                                      children: [
                                        for (final g
                                            in _groupController.myGroups)
                                          buildTypeOption(
                                            label: g.name,
                                            isSelected:
                                                selectedGroupId == (g.id) &&
                                                selectedFriendName == null,
                                            onTap: () => _selectGroup(g.id),
                                          ),
                                      ],
                                    ),
                                  ],
                                  if (hasFriends) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 8,
                                      children: [
                                        for (final f
                                            in _friendController.friendList)
                                          buildTypeOption(
                                            label: f.name,
                                            isSelected:
                                                selectedFriendName ==
                                                    (f.name) &&
                                                selectedGroupId == null,
                                            onTap: () =>
                                                _selectFriend((f.name).trim()),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ).popIn(_aStudyWith),
                        ),
                      ],
                    ],
                  );
                }),
                SizedBox(height: 7),

                Opacity(
                  opacity: _isFormValid ? 1.0 : 0.4,
                  child: IgnorePointer(
                    ignoring: !_isFormValid,
                    child: CompleteButton(
                      label: 'Complete',
                      color: widget.categoryColor,
                      onTap: _submit,
                    ).popIn(_aSubmit),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
