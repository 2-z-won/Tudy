import 'package:flutter/material.dart';
import 'package:frontend/components/check.dart';

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
    bool isTimeSelected = true;
    final TextEditingController hoursController = TextEditingController();
    final TextEditingController minutesController = TextEditingController();

    @override
    void dispose() {
      hoursController.dispose();
      minutesController.dispose();
      super.dispose();
    }

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
          SingleChildScrollView(
            child: Column(
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
                        '🔥 목표 🔥',
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

                      const SizedBox(height: 15),

                      // 목표 시간 입력 필드
                      if (isTimeSelected) ...[
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                child: TextField(
                                  controller: hoursController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ),
                              const Text(' h  :  '),
                              SizedBox(
                                width: 40,
                                child: TextField(
                                  controller: minutesController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ),
                              const Text(' m'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],

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
              ],
            ),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
