import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/Todo/model/allGoalByOneCategory.dart';
import 'package:frontend/api/Todo/model/goal_model.dart';
import 'package:frontend/components/Todo/TodoColor.dart';
import 'package:frontend/components/Todo/TodoList/SectionCard.dart';
import 'package:frontend/components/Todo/TodoList/component/TodoList_component.dart';
import 'package:frontend/components/Todo/TodoList/component/pop_transitions.dart';
import 'package:frontend/components/check.dart';
import 'package:frontend/constants/colors.dart';
import 'package:intl/intl.dart';
import 'dart:ui' show lerpDouble;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:percent_indicator/circular_percent_indicator.dart';

class TodoDetailController {
  Future<void> Function()? playExit;
}

class TodoDetailForm extends StatefulWidget {
  final Goal goal;
  final VoidCallback? onExit;
  final TodoDetailController? controller;

  final void Function({required String title, required Set<String> types})
  onSubmit;

  const TodoDetailForm({
    super.key,
    required this.onSubmit,
    this.controller,
    required this.goal,
    this.onExit,
  });

  @override
  State<TodoDetailForm> createState() => _TodoDetailFormState();
}

class _TodoDetailFormState extends State<TodoDetailForm>
    with TickerProviderStateMixin {
  final TextEditingController _title = TextEditingController();

  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery, // 갤러리에서 선택 (카메라는 ImageSource.camera)
      maxWidth: 1024, // 원하는 경우 리사이즈
    );

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  late bool isTimeSelected;
  late Duration targetDuration;
  late Duration currentDuration;

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '${h}h  :  ${m}m';
  }

  bool _startProgress = false;

  double get _targetPercent => widget.goal.completed
      ? 1.0
      : (isTimeSelected ? widget.goal.timeProgressRatio : 0.0);
  double get _shownPercent => _startProgress ? _targetPercent : 0.0;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Duration selectedDuration = const Duration(hours: 0, minutes: 0);

  int? selectedGroupId;
  String? selectedFriendName;
  bool get isGroupGoal => selectedGroupId != null;
  bool get isFriendGoal => selectedFriendName != null;

  late final AnimationController _inCtrl;
  late final List<Animation<double>> _anims;

  late final AnimationController _outCtrl;
  late final List<Animation<double>> _outAnims;

  @override
  void initState() {
    super.initState();
    // 헤더, 상단Row(카테고리+목표), 기간 섹션, 인증 섹션, 진행률 섹션, 버튼 = 6개
    _inCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anims = Stagger.by(
      _inCtrl,
      count: 7,
      step: .12,
      span: .45,
      curve: Curves.easeOut,
    );
    _inCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 80), () {
          if (mounted) setState(() => _startProgress = true);
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inCtrl.forward();
    });

    // ==== 퇴장 애니메이션 ====
    _outCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _outAnims = Stagger.by(
      _outCtrl,
      count: 7, // [제목, 카드1, 카드2, +추가]
      step: .12, // 제목 먼저 → 카드1 → 카드2 → +추가
      span: .45,
      curve: Curves.easeIn,
    );

    widget.controller?.playExit = playExit;

    isTimeSelected = widget.goal.proofType == 'TIME';
    startDate = widget.goal.startDate;
    endDate = widget.goal.endDate;

    targetDuration = Duration(seconds: widget.goal.targetTime ?? 0);
    currentDuration = Duration(seconds: widget.goal.totalDuration ?? 0);
  }

  @override
  void dispose() {
    _inCtrl.dispose();
    _outCtrl.dispose();
    super.dispose();
  }

  Future<void> playExit() async {
    if (mounted && _startProgress) setState(() => _startProgress = false);
    await _outCtrl.forward();
  }

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
                'Todo Detail',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "GmarketSans",
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              GestureDetector(
                // ✅ 변경
                onTap: widget.onExit, // ← 뒤로가기 콜백
                child: const Icon(Icons.exit_to_app),
              ),
            ],
          ),
        ).popIn(_anims[0]).popOut(_outAnims[0]),
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
                          color:
                              mainColors[(widget.goal.category.color - 1).clamp(
                                0,
                                mainColors.length - 1,
                              )],
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [dropShadow],
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.goal.category.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  widget.goal.isFriendGoal &&
                                          (widget.goal.friendName ?? '')
                                              .isNotEmpty
                                      ? Text(
                                          '(${widget.goal.friendName})',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        )
                                      : widget.goal.isGroupGoal
                                      ? Text(
                                          '(그룹 ${widget.goal.groupId})',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                            Spacer(),
                            Align(
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
                          ],
                        ),
                      ).popIn(_anims[1]).popOut(_outAnims[1]),
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      flex: 249,
                      child: SectionCard(
                        height: 85,
                        title: '🔥Goal🔥',
                        contentAlignment: Alignment.centerLeft,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            widget.goal.title,
                            style: TextStyle(color: TextColor, fontSize: 14),
                          ),
                        ),
                      ).popIn(_anims[2]).popOut(_outAnims[2]),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                SectionCard(
                  height: 73,
                  title: '📆 Duration',
                  child: Text(
                    "${DateFormat('yyyy.MM.dd').format(startDate)}  ~  ${DateFormat('yyyy.MM.dd').format(endDate)}",
                    style: TextStyle(
                      fontFamily: "GmarketSans",
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ).popIn(_anims[3]).popOut(_outAnims[3]),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 220,
                      child: SectionCard(
                        height: 162,
                        title: '⏱️ Verification',
                        child: isTimeSelected
                            ? Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    buildTypeOption(
                                      label: '목표 시간',
                                      isSelected: true,
                                      onTap: () {},
                                    ),
                                    buildDurationText(_fmt(targetDuration)),

                                    buildTypeOption(
                                      label: '현재 측정 시간',
                                      isSelected: true,
                                      onTap: () {},
                                    ),
                                    buildDurationText(_fmt(currentDuration)),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: widget.goal.completed
                                    ? buildTypeOption(
                                        label: '사진 인증',
                                        isSelected: true,
                                        onTap: () {},
                                      )
                                    : Column(
                                        children: [
                                          buildTypeOption(
                                            label: '사진 인증',
                                            isSelected: true,
                                            onTap: () {},
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: _pickImage,
                                              child: _imageFile == null
                                                  ? Icon(
                                                      Icons
                                                          .add_photo_alternate_outlined,
                                                      color:
                                                          mainColors[(widget
                                                                      .goal
                                                                      .category
                                                                      .color -
                                                                  1)
                                                              .clamp(
                                                                0,
                                                                mainColors
                                                                        .length -
                                                                    1,
                                                              )],
                                                      size: 24,
                                                    )
                                                  : Row(children: [Image.file(
                                                      _imageFile!,
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),Text("인증하기")],)
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                      ).popIn(_anims[4]).popOut(_outAnims[4]),
                    ),
                    const SizedBox(width: 7),

                    Expanded(
                      flex: 129,
                      child: SectionCard(
                        height: 162,
                        title: '🌱 Progress',
                        child: CircularPercentIndicator(
                          radius: 50.0, // 원 크기
                          lineWidth: 13.0, // 선 두께
                          percent: _shownPercent,
                          animation: true,
                          animationDuration: 1200,
                          restartAnimation: true, // ✅ percent 바뀔 때마다 다시 시작
                          animateFromLastPercent: true, // ✅ 이전값에서 부드럽게
                          center: buildProgressCenter(
                            color:
                                mainColors[(widget.goal.category.color - 1)
                                    .clamp(0, mainColors.length - 1)],
                            isDone: widget.goal.completed,
                            isTimeMode: isTimeSelected, // 시간이면 true
                            percent: widget.goal.timeProgressRatio, //50퍼
                          ),
                          progressColor:
                              mainColors[(widget.goal.category.color - 1).clamp(
                                0,
                                mainColors.length - 1,
                              )], // 채워지는 부분
                          backgroundColor: Colors.grey.shade200, // 안 채워진 부분
                          circularStrokeCap: CircularStrokeCap.round, // 끝부분 둥글게
                        ),
                      ).popIn(_anims[5]).popOut(_outAnims[5]),
                    ),
                  ],
                ),
                SizedBox(height: 7),
                widget.goal.completed
                    ? SizedBox.shrink()
                    : CompleteButton(
                        color:
                            mainColors[(widget.goal.category.color - 1).clamp(
                              0,
                              mainColors.length - 1,
                            )],
                        label: 'Edit',
                        onTap: () {},
                      ).popIn(_anims[6]).popOut(_outAnims[6]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildDurationText(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 7, bottom: 10),
    child: Align(
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: "GmarketSans",
          fontWeight: FontWeight.w700,
          color: Colors.black,
          fontSize: 15,
          letterSpacing: 2,
        ),
      ),
    ),
  );
}

Widget buildProgressCenter({
  required bool isDone, // 완료 여부
  required bool isTimeMode, // 측정 방식이 '시간'인지
  required double percent, // 0.0 ~ 1.0
  required Color color,
}) {
  if (isDone) {
    return Text(
      "Done",
      style: TextStyle(
        fontFamily: "GmarketSans",
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: color,
      ),
    );
  } else if (isTimeMode) {
    return Text(
      "${(percent * 100).round()}%",
      style: TextStyle(
        fontFamily: "GmarketSans",
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: color,
      ),
    );
  } else {
    // 이미지처럼: 빨간 물음표 + 안내 문구(두 줄)
    return Padding(
      padding: EdgeInsetsGeometry.only(top: 6, bottom: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.question_mark_rounded, color: color, size: 20),
          SizedBox(height: 2),
          Text(
            "사진을\n제출해주세요",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: SubTextColor, height: 1.4),
          ),
        ],
      ),
    );
  }
}
