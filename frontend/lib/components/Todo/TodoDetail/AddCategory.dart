import 'package:flutter/material.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:get/get.dart';
import 'package:frontend/components/check.dart';
import 'package:frontend/components/Todo/Todo.dart';
import 'package:frontend/components/Todo/TodoColor.dart';
import 'package:frontend/api/Todo/controller/category_controller.dart';

class AddCategoryUI extends StatefulWidget {
  final VoidCallback onClose;
  const AddCategoryUI({super.key, required this.onClose});

  @override
  State<AddCategoryUI> createState() => _AddCategoryUIState();
}

class _AddCategoryUIState extends State<AddCategoryUI> {
  final CategoryController _categoryController = CategoryController();

  final TextEditingController nameController = TextEditingController();

  List<Color> colorOptions = mainColors;

  int selectedColorIndex = 0; // 초기 선택 인덱스

  bool isStudySelected = false;
  bool isExcerciseSelected = false;
  bool isEtcSelected = false;

  bool isTimeSelected = true;
  late Color mainColor;
  late Color subColor;

  String? userId;

  @override
  void initState() {
    super.initState();
    mainColor = Color(0xFFFF4A4A);
    subColor = const Color(0xFFFFE1E1);
    isStudySelected = true;

    loadUserId();
  }

  Future<void> loadUserId() async {
    final uid = await getUserIdFromStorage();
    setState(() {
      userId = uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      decoration: BoxDecoration(
        color: subColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "➕ 카테고리 추가",
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              Spacer(),
              TextButton(
                onPressed: () async {
                  if (userId == null) {
                    _categoryController.errorMessage.value =
                        "로그인 정보가 없습니다. 다시 로그인해주세요.";
                    return;
                  }

                  await _categoryController.addCategory(
                    userId: userId!,
                    name: nameController.text,
                    colorIndex: selectedColorIndex + 1,
                    categoryType: isStudySelected
                        ? 'STUDY'
                        : isExcerciseSelected
                        ? 'EXERCISE'
                        : 'ECT',
                  );

                  // 결과 메시지 출력
                  if (!_categoryController.errorMessage.isNotEmpty) {
                    widget.onClose(); // 닫기
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
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // ✅ 위로 정렬
                  children: [
                    Text(
                      '✍🏻 카테고리 명',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        keyboardType: TextInputType.multiline, // ✅ 줄바꿈 허용
                        maxLines: null, // ✅ 무제한 줄바꿈 가능
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF303030),
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '카테고리 명을 입력해주세요',
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
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '분류',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    const SizedBox(height: 15),

                    // 시간 측정
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isStudySelected = true;

                          isEtcSelected = false;
                          isExcerciseSelected = false;
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 5),
                          isStudySelected
                              ? const CheckIcon()
                              : const NoCheckIcon(),
                          const SizedBox(width: 5),
                          const Text('공부', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    //
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isStudySelected = false;
                          isEtcSelected = false;
                          isExcerciseSelected = true;
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 5),
                          isExcerciseSelected
                              ? const CheckIcon()
                              : const NoCheckIcon(),
                          const SizedBox(width: 5),
                          const Text('운동', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isEtcSelected = true;
                          isExcerciseSelected = false;
                          isStudySelected = false;
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(width: 5),
                          isEtcSelected
                              ? const CheckIcon()
                              : const NoCheckIcon(),
                          const SizedBox(width: 5),
                          const Text('기타', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎨 색상',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Wrap(
                        spacing: 32,
                        runSpacing: 15,
                        children: List.generate(colorOptions.length, (index) {
                          final color = colorOptions[index];
                          final isSelected = selectedColorIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColorIndex = index;
                                mainColor = mainColors[index];
                                subColor = subColors[index];
                              });
                            },

                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
          _categoryController.errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _categoryController.errorMessage.value,
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

          SizedBox(height: 60),
        ],
      ),
    );
  }
}
