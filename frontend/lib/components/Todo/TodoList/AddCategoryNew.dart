import 'package:flutter/material.dart';
import 'package:frontend/components/Todo/TodoColor.dart';
import 'package:frontend/components/Todo/TodoList/SectionCard.dart';
import 'package:frontend/components/Todo/TodoList/category_logo.dart';
import 'package:frontend/components/Todo/TodoList/component/TodoList_component.dart';
import 'package:frontend/components/Todo/TodoList/component/pop_transitions.dart';
import 'package:frontend/components/check.dart';
import 'package:frontend/constants/colors.dart';
import 'dart:ui' show lerpDouble;
import 'package:get/get.dart';
import 'package:frontend/api/Todo/controller/category_controller.dart';
import 'package:frontend/utils/auth_util.dart';

class AddCategoryForm extends StatefulWidget {
  final VoidCallback? onExit;

  /// 제출 시 선택값 전달
  final void Function({required String title}) onSubmit;

  const AddCategoryForm({super.key, required this.onSubmit, this.onExit});

  @override
  State<AddCategoryForm> createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm>
    with TickerProviderStateMixin {
  final TextEditingController _title = TextEditingController();

  final List<Color> colorOptions = mainColors;
  int selectedColorIndex = 0;

  bool isStudySelected = false;
  bool isExcerciseSelected = false;
  bool isEtcSelected = false;

  final List<String> emojiIcons = const [
    '✍🏻',
    '✏️',
    '📚',
    '💻',
    '🧠',
    '🍳',
    '⚒️',
    '👟',
    '🏋️',
    '👊🏻',
    '🔥',
    '📍',
    '📌',
    '🍀',
  ];

  bool _iconOpen = false;
  String selectedEmoji = '✏️'; // 표시용
  final String _iconKey = 'pencil';

  // 폭 상태
  double _lastMaxW = 0;

  final _categoryController = Get.find<CategoryController>();
  String? _userId;

  Future<void> _loadUserId() async {
    final uid = await getUserIdFromStorage();
    setState(() => _userId = uid);
  }

  bool get _isFormValid {
    final nameValid = _title.text.trim().isNotEmpty;
    final iconValid = selectedEmoji.isNotEmpty; // 필요하면 기본값 제외 검사
    final colorValid = selectedColorIndex >= 0;
    final typeValid = isStudySelected || isExcerciseSelected || isEtcSelected;
    return nameValid && iconValid && colorValid && typeValid;
  }

  Future<void> _submit() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    final String categoryType = isStudySelected
        ? 'STUDY'
        : (isExcerciseSelected ? 'EXERCISE' : 'ETC');

    final int colorIndex1Based = selectedColorIndex + 1;

    await _categoryController.addCategory(
      userId: _userId!,
      name: _title.text.trim(),
      colorIndex: colorIndex1Based,
      categoryType: categoryType,
      selectedEmoji: selectedEmoji,
    );

    if (!_categoryController.errorMessage.value.isNotEmpty) {
      // 부모에게 알려서 목록 갱신 트리거(필요 시)
      widget.onSubmit(title: _title.text.trim());
      widget.onExit?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_categoryController.errorMessage.value)),
      );
    }
  }

  late final AnimationController _enterCtrl;
  late final Animation<double> _aHeader,
      _aIcon,
      _aCat,
      _aColor,
      _aType,
      _aSubmit;

  late final AnimationController _exitCtrl;
  late final Animation<double> _xHeader,
      _xIcon,
      _xCat,
      _xColor,
      _xType,
      _xSubmit;

  bool _exiting = false;

  @override
  void dispose() {
    _enterCtrl.dispose();
    _exitCtrl.dispose();
    _title.dispose();
    super.dispose();
  }

  void _toggleIconPane() {
    setState(() {
      _iconOpen = !_iconOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();

    isStudySelected = true;

    _title.addListener(() => setState(() {}));

    // ======= ✅ 순차 등장 애니메이션 세팅 (천천히) =======
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _aHeader = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.00, 0.20, curve: Curves.easeOut),
    );

    // 5단계 스태거 (아이콘 → 카테고리 → Color → Type → 제출)
    _aIcon = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
    );
    _aCat = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.12, 0.47, curve: Curves.easeOut),
    );
    _aColor = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.28, 0.65, curve: Curves.easeOut),
    );
    _aType = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.44, 0.83, curve: Curves.easeOut),
    );
    _aSubmit = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.62, 1.00, curve: Curves.easeOut),
    );

    // ✅ 퇴장 컨트롤러 (속도는 취향대로)
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // ✅ 헤더 → 아이콘 → 카테고리 → 컬러 → 타입 → 제출 순서로 스태거
    _xHeader = CurvedAnimation(
      parent: _exitCtrl,
      curve: const Interval(0.00, 0.55, curve: Curves.easeIn),
    );
    _xIcon = CurvedAnimation(
      parent: _exitCtrl,
      curve: const Interval(0.08, 0.63, curve: Curves.easeIn),
    );
    _xCat = CurvedAnimation(
      parent: _exitCtrl,
      curve: const Interval(0.16, 0.71, curve: Curves.easeIn),
    );
    _xColor = CurvedAnimation(
      parent: _exitCtrl,
      curve: const Interval(0.24, 0.79, curve: Curves.easeIn),
    );
    _xType = CurvedAnimation(
      parent: _exitCtrl,
      curve: const Interval(0.32, 0.87, curve: Curves.easeIn),
    );
    _xSubmit = CurvedAnimation(
      parent: _exitCtrl,
      curve: const Interval(0.40, 0.95, curve: Curves.easeIn),
    );

    // 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 폼만 그리므로 배경색은 부모가 정합니다. (필요하면 최상단 Container color로 지정)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더: 팝인 → 팝아웃(오른쪽으로 살짝)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Add Category',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "GmarketSans",
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 8),
              CategoryLogo(color: colorOptions[selectedColorIndex]),
              Spacer(),
              GestureDetector(
                child: const Icon(Icons.exit_to_app),
                onTap: () async {
                  if (_exiting) return;
                  _exiting = true;
                  await _exitCtrl.forward();
                  if (!mounted) return;
                  widget.onExit?.call();
                },
              ),
            ],
          ),
        ).popIn(_aHeader).popOut(_xHeader, to: const Offset(0.12, 0)),
        const SizedBox(height: 5),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 상단: Icon / Category 입력
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 7.0;
                  final maxW = constraints.maxWidth;
                  _lastMaxW = maxW;

                  // 닫힘(기본) 상태의 폭: 기존 flex(80 : 274) 비율로 계산
                  final startIcon = (maxW - gap) * (80.0 / (80.0 + 274.0));
                  final startCat = (maxW - gap) - startIcon;

                  // 열림 상태 목표: 아이콘 330, 카테고리 20 (화면이 작은 경우 비율 축소)
                  const double minIconOpen = 330.0;
                  const double catOpenRaw = 20.0;
                  final double avail = maxW - gap;

                  double targetIcon, targetCat;
                  if (avail >= minIconOpen + catOpenRaw) {
                    targetCat = catOpenRaw;
                    targetIcon = avail - targetCat;
                  } else {
                    final k = avail / (minIconOpen + catOpenRaw);
                    targetIcon = minIconOpen * k;
                    targetCat = catOpenRaw * k;
                  }

                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: _iconOpen ? 1 : 0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, t, _) {
                      final wIcon = lerpDouble(startIcon, targetIcon, t)!;
                      final wCat = lerpDouble(startCat, targetCat, t)!;
                      final cardH = lerpDouble(85.0, 128.0, t)!;

                      return Row(
                        children: [
                          // 아이콘 카드 (탭 → 열림/닫힘)  ✅ 순차등장 + 팝업
                          GestureDetector(
                            onTap: _toggleIconPane,
                            child:
                                SizedBox(
                                      width: wIcon,
                                      height: cardH,
                                      child: SectionCard(
                                        height: cardH,
                                        title: '📍Icon',
                                        child: _iconOpen
                                            ? GridView.count(
                                                crossAxisCount: 7,
                                                crossAxisSpacing: 6,
                                                mainAxisSpacing: 6,
                                                shrinkWrap: true,
                                                children: emojiIcons.map((
                                                  emoji,
                                                ) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedEmoji = emoji;
                                                        _iconOpen = false;
                                                      });
                                                    },
                                                    child: Text(
                                                      emoji,
                                                      style: const TextStyle(
                                                        fontSize: 27,
                                                        fontFamily:
                                                            "GmarketSans",
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              )
                                            : Text(
                                                selectedEmoji,
                                                style: const TextStyle(
                                                  fontSize: 25,
                                                  fontFamily: "GmarketSans",
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                      ),
                                    )
                                    .popIn(_aIcon)
                                    .popOut(_xIcon, to: const Offset(0.12, 0)),
                          ),

                          const SizedBox(width: gap),

                          // 카테고리 카드 ✅ 순차등장 + 팝업
                          SizedBox(
                            width: wCat,
                            height: cardH,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [dropShadow],
                              ),
                              child: Builder(
                                builder: (_) {
                                  // 1) 제목: wCat이 100~140 사이에서 1→0으로 사라짐
                                  final titleAlpha = ((wCat - 100.0) / 40.0)
                                      .clamp(0.0, 1.0);

                                  // 2) 내용(TextField): t가 0.05~0.40에서 1→0으로 사라짐
                                  final fade = ((t - 0.05) / 0.35).clamp(
                                    0.0,
                                    1.0,
                                  );
                                  final vis = 1.0 - fade;

                                  return Column(
                                    children: [
                                      ClipRect(
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          heightFactor: titleAlpha,
                                          child: Opacity(
                                            opacity: titleAlpha,
                                            child: Text(
                                              '✍️ Category',
                                              style: TextStyle(
                                                fontFamily: "GmarketSans",
                                                fontWeight: FontWeight.w700,
                                                color: TextColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: titleAlpha > 0 ? 8 : 0),
                                      Expanded(
                                        child: Center(
                                          child: Opacity(
                                            opacity: vis,
                                            child: IgnorePointer(
                                              ignoring: vis < 0.6,
                                              child: TextField(
                                                textAlign: TextAlign.center,
                                                controller: _title,
                                                decoration: InputDecoration(
                                                  hintText: '카테고리 명을 작성해주세요',
                                                  hintStyle: const TextStyle(
                                                    color: Color(0xFFA9A9A9),
                                                    fontSize: 12,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                      EdgeInsets.all(0),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ).popIn(_aCat).popOut(_xCat, to: const Offset(0.12, 0)),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 7),

              // 중단: Color / Type
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color 카드 ✅ 순차등장 + 팝업
                  Expanded(
                    flex: 249,
                    child: SectionCard(
                      height: 130,
                      title: '✏️ Color',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: List.generate(colorOptions.length, (
                              index,
                            ) {
                              final color = colorOptions[index];
                              final isSelected = selectedColorIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColorIndex = index;
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ).popIn(_aColor).popOut(_xColor, to: const Offset(0.12, 0)),
                  ),
                  const SizedBox(width: 7),

                  // Type 카드 ✅ 순차등장 + 팝업
                  Expanded(
                    flex: 100,
                    child: SectionCard(
                      height: 130,
                      title: '📌 Type',
                      contentAlignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildTypeOption(
                            label: '공부',
                            isSelected: isStudySelected,
                            onTap: () {
                              setState(() {
                                isStudySelected = true;
                                isExcerciseSelected = false;
                                isEtcSelected = false;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          buildTypeOption(
                            label: '운동',
                            isSelected: isExcerciseSelected,
                            onTap: () {
                              setState(() {
                                isStudySelected = false;
                                isExcerciseSelected = true;
                                isEtcSelected = false;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          buildTypeOption(
                            label: '기타',
                            isSelected: isEtcSelected,
                            onTap: () {
                              setState(() {
                                isStudySelected = false;
                                isExcerciseSelected = false;
                                isEtcSelected = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ).popIn(_aType).popOut(_xType, to: const Offset(0.12, 0)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 하단 버튼 ✅ 마지막 순서로 팝업
              Opacity(
                opacity: _isFormValid ? 1.0 : 0.4,
                child: IgnorePointer(
                  ignoring: !_isFormValid,
                  child: CompleteButton(
                    label: 'Complete',
                    onTap: _submit,
                    color: colorOptions[selectedColorIndex],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
