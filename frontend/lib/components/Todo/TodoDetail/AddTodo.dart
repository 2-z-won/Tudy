import 'package:flutter/material.dart';
import 'package:frontend/api/Todo/controller/goal_controller.dart';
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/components/check.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:frontend/api/Friend/controller/FriendListController.dart';
import 'package:frontend/api/Group/controller/GroupController.dart';
import 'package:get/get.dart';

class AddTodo extends StatefulWidget {
  final VoidCallback onClose;
  final String category;
  final Color mainColor;
  final Color subColor;

  const AddTodo({
    super.key,
    required this.onClose,
    required this.category,
    required this.mainColor,
    required this.subColor,
  });

  @override
  State<AddTodo> createState() => _TodoDetailState();
}

class _TodoDetailState extends State<AddTodo> {
  final GoalController _goalController = GoalController();
  final MyGroupController _groupController = Get.put(MyGroupController());
  final FriendListController _friendController = Get.put(
    FriendListController(),
  );

  bool isTimeSelected = true;
  bool isFriendSelected = false;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Duration selectedDuration = const Duration(hours: 0, minutes: 0);

  @override
  void initState() {
    super.initState();

    loadUserId();
  }

  String? userId;

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

  Future<void> loadUserId() async {
    final uid = await getUserIdFromStorage();
    setState(() {
      userId = uid;
    });

    if (uid != null) {
      await _groupController.fetchMyGroups(uid);
      await _friendController.fetchFriends(uid);
    }
  }

  TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: 386,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      decoration: BoxDecoration(
        color: widget.subColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 6, left: 10),
                decoration: BoxDecoration(
                  color: widget.mainColor,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                widget.category,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              Spacer(),
              TextButton(
                onPressed: () async {
                  if (userId == null) {
                    _goalController.errorMessage.value =
                        "로그인 정보가 없습니다. 다시 로그인해주세요.";
                    return;
                  }
                  final formatter = DateFormat('yyyy-MM-dd');

                  final newGoal = AddGoal(
                    userId: userId!, // userId는 String? → int로 변환 필요
                    title: titleController.text,
                    categoryName: widget.category,
                    startDate: formatter.format(startDate),
                    endDate: formatter.format(endDate),
                    isGroupGoal: false,
                    groupId: null,
                    isFriendGoal: false,
                    friendName: null,
                    proofType: isTimeSelected ? "TIME" : "IMAGE",
                    targetTime: isTimeSelected
                        ? selectedDuration.inSeconds
                        : null,
                  );

                  await _goalController.addGoal(newGoal);

                  if (!_goalController.errorMessage.value.isNotEmpty) {
                    widget.onClose();
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '완료',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),

              SizedBox(width: 10),
            ],
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(15, 12, 15, 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // ✅ 위로 정렬
                    children: [
                      Text(
                        '🔥 목표 🔥',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: titleController,
                          keyboardType: TextInputType.multiline, // ✅ 줄바꿈 허용
                          maxLines: null, // ✅ 무제한 줄바꿈 가능
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF303030),
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: '오늘의 목표를 작성해주세요',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFCCCCCC),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(15, 12, 15, 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    mainAxisAlignment: MainAxisAlignment.start,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '📆 기간',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
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
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                "  ~  ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
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
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✏️ 목표 달성 인증 방식',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      const SizedBox(height: 15),

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
                              '시간 측정 ',
                              style: TextStyle(fontSize: 12),
                            ),
                            const Text(
                              '(목표 시간 설정)',
                              style: TextStyle(fontSize: 8),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 13),

                      // 타이머 텍스트
                      GestureDetector(
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
                            '${selectedDuration.inHours.toString().padLeft(2, '0')} h  :  ${(selectedDuration.inMinutes % 60).toString().padLeft(2, '0')} m',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

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
                            const Text('사진 인증', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Obx(() {
                  final hasGroup = _groupController.myGroups.isNotEmpty;
                  final hasFriend = _friendController.friendList.isNotEmpty;

                  if (!hasGroup && !hasFriend)
                    return SizedBox(); // 아무것도 없으면 안 보이게

                  return Container(
                    padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '👤 그룹 또는 친구와 함께하기',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(height: 15),

                        // 그룹 리스트
                        if (hasGroup)
                          ..._groupController.myGroups.map(
                            (group) => GestureDetector(
                              onTap: () {
                                // 선택 처리 로직
                              },
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  // 체크박스는 나중에 조건 추가
                                  const NoCheckIcon(),
                                  const SizedBox(width: 5),
                                  Text(
                                    group.name,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 15),

                        // 친구 리스트
                        if (hasFriend)
                          ..._friendController.friendList.map(
                            (friend) => GestureDetector(
                              onTap: () {
                                // 선택 처리 로직
                              },
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  const NoCheckIcon(),
                                  const SizedBox(width: 5),
                                  Text(
                                    friend.name,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                _goalController.errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _goalController.errorMessage.value,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 10,
                              color: Color(0xFFE94F4F),
                              decorationColor: Color(0xFFE94F4F),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(height: 12),
              ],
            ),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
