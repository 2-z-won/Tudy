import 'package:flutter/material.dart';
import 'package:frontend/components/check.dart';
import 'package:frontend/components/Todo/Todo.dart';

class AddCategory extends StatefulWidget {
  final VoidCallback onClose;
  final String category;
  final Color mainColor;
  final Color subColor;

  const AddCategory({
    super.key,
    required this.onClose,
    required this.category,
    required this.mainColor,
    required this.subColor,
  });

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  List<Color> colorOptions = [
    Color(0xFFFF4A4A), // 빨강
    Color(0xFFFF9A3E), // 주황
    Color(0xFFFFEB3B), // 노랑
    Color(0xFF00E676), // 연두
    Color(0xFF2979FF), // 파랑
    Color(0xFFE040FB), // 보라
    Color(0xFFE0E0E0), // 회색1
    Color(0xFFE0E0E0), // 회색2
  ];

  int selectedColorIndex = 0; // 초기 선택 인덱스

  bool isTimeSelected = true;
  late Color mainColor;
  late Color subColor;

  @override
  void initState() {
    super.initState();
    mainColor = Color(0xFFFF4A4A); // ex: Colors.grey
    subColor = const Color(0xFFFFE1E1); // 기본 배경색
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
                onPressed: widget.onClose,
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
                  children: const [
                    Text(
                      '✍🏻 카테고리 명',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
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
                                mainColor = colorOptions[index];
                                subColor = getSubColor(
                                  mainColor,
                                ); // ✅ 여기서 배경 업데이트
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
          SizedBox(height: 80),
        ],
      ),
    );
  }
}
