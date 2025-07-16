import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:get/get.dart';

class EditMypageView extends StatefulWidget {
  const EditMypageView({super.key});

  @override
  State<EditMypageView> createState() => _EditMypageViewState();
}

class _EditMypageViewState extends State<EditMypageView> {
  String? editingField;

  final TextEditingController nameController = TextEditingController(
    text: "김효정",
  );
  final TextEditingController idController = TextEditingController(
    text: "loopy",
  );
  final TextEditingController pwController = TextEditingController(
    text: "12345678",
  );
  final TextEditingController emailController = TextEditingController(
    text: "###@pusan.ac.kr",
  );
  final TextEditingController birthController = TextEditingController(
    text: "2004.12.25",
  );
  final TextEditingController deptController = TextEditingController(
    text: "정보컴퓨터공학부",
  );

  String selectedCollege = "정보의생명공학대학";

  final List<String> colleges = [
    '치의학전문대학원',
    '한의학전문대학원',
    '인문대학',
    '사회과학대학',
    '자연과학대학',
    '공과대학',
    '법과대학',
    '사범대학',
    '상과대학',
    '약학대학',
    '의과대학',
    '치과대학',
    '예술대학',
    '학부대학',
    '스포츠과학부',
    '관광컨벤션학부',
    '나노과학기술대학',
    '생명자원과학대학',
    '간호대학',
    '경영대학',
    '생활과학대학',
    '경제통상대학',
    '이공대학',
    '사회문화대학',
    '정보의생명공학대학',
    '부속기관',
    '부속연구소',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 40),
                color: const Color(0xFF2353A6),
                height: 110,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "학  생  증",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // 포커스 해제 + 편집 상태 종료
                    FocusScope.of(context).unfocus();
                    setState(() => editingField = null);
                  },
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Spacer(),
                        buildInputField("NAME", nameController),
                        buildInputField("ID", idController, editable: false),
                        buildInputField(
                          "Password",
                          pwController,
                          obscureText: true,
                        ),
                        buildInputField(
                          "E-mail",
                          emailController,
                          editable: false,
                        ),
                        buildInputField("Birth", birthController),
                        buildDropdown("단과대", colleges, selectedCollege, (val) {
                          setState(() => selectedCollege = val!);
                        }),
                        buildInputField("학과/학부", deptController),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 25,
                                ),
                              ),
                              onPressed: () {
                                // 취소 동작
                                FocusScope.of(context).unfocus();
                                setState(() => editingField = null);
                                Get.back();
                              },
                              child: const Text(
                                '취소',
                                style: TextStyle(
                                  color: SubTextColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 25,
                                ),
                              ),
                              onPressed: () {
                                // 저장 동작
                                FocusScope.of(context).unfocus();
                                setState(() => editingField = null);
                                // TODO: 저장 로직
                                Get.back();
                              },
                              child: const Text(
                                '저장',
                                style: TextStyle(
                                  color: SubTextColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                height: 55,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/pnu_logo.png',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '부  산  대  학  교',
                      style: TextStyle(
                        color: Color(0xFF2353A6),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 125,
                  height: 125,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Color(0xFFF1F1F1), width: 1),
                  ),
                  child: Image.asset('images/profile.jpg'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputField(
    String label,
    TextEditingController controller, {
    bool editable = true,
    bool obscureText = false,
  }) {
    final bool isEditing = editingField == label;

    return GestureDetector(
      onTap: editable
          ? () {
              if (label == "Password") {
                showPasswordCheckDialog(); // ✅ 다이얼로그 호출
              } else {
                setState(() => editingField = label);
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        height: 45,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 0, 15, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFDCDAE2), width: 2),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
            ),
            const Spacer(),
            isEditing
                ? Expanded(
                    flex: 3,
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      obscureText: obscureText,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration.collapsed(hintText: ''),
                      onEditingComplete: () {
                        setState(() => editingField = null);
                      },
                    ),
                  )
                : Text(
                    obscureText
                        ? '*' * controller.text.length
                        : controller.text,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
            if (!isEditing && editable && label != "ID") ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: SubTextColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildDropdown(
    String label,
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      width: double.infinity,
      height: 45,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFDCDAE2), width: 1.5),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              alignment: Alignment.centerRight,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showPasswordCheckDialog() async {
    final TextEditingController pwCheckController = TextEditingController();
    bool isError = false;

    await showDialog(
      context: context,
      barrierDismissible: true,

      barrierColor: const Color(0xFF6E6E6E).withOpacity(0.2),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
              child: Container(
                width: 310,

                padding: const EdgeInsets.fromLTRB(23, 21, 23, 21),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE1DDD4)),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 12.9,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "현재 비밀번호를 입력해주세요",
                      style: TextStyle(fontSize: 14, color: SubTextColor),
                    ),
                    const SizedBox(height: 15),

                    // 입력창 + 에러 밑줄
                    Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFDCDAE2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: pwCheckController,
                        obscureText: true,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: TextStyle(fontSize: 16, color: TextColor),
                      ),
                    ),

                    // 에러 메시지 표시
                    if (isError) ...[
                      SizedBox(height: 5),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "비밀번호가 일치하지 않습니다",
                          style: TextStyle(
                            color: Color(0xFFFF2C2C),
                            fontSize: 12,
                            decoration: TextDecoration.underline, // 밑줄 추가
                            decorationColor: Color(0xFFFF2C2C),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ] else
                      const SizedBox(height: 29),

                    GestureDetector(
                      onTap: () {
                        // if (pwCheckController.text == pwController.text) {
                        //   Navigator.pop(context);
                        //   this.setState(() {
                        //     editingField = "Password";
                        //   });
                        // } else {
                        //   setState(() {
                        //     isError = true;
                        //   });
                        // }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "완료",
                        style: TextStyle(fontSize: 14, color: SubTextColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
