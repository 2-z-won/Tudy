import 'package:flutter/material.dart';
import 'package:frontend/api/SignupLogin/controller/signup_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/LoginSignup/component.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({super.key});

  @override
  State<SingupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  final SignUpController controller = Get.put(SignUpController());

  @override
  void initState() {
    super.initState();
    // ✅ 전달된 이메일 가져와서 컨트롤러에 넣기
    final email = Get.arguments as String? ?? '';
    controller.emailController.text = email;
  }

  Widget buildCollegeField() {
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

    String? selectedCollege;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(left: 7, bottom: 1),
              child: Text(
                "단과대",
                style: TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
              ),
            ),
            Container(
              width: double.infinity,
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE1DDD4), width: 2),
                borderRadius: BorderRadius.circular(3),
              ),
              padding: const EdgeInsets.only(left: 10, right: 5),
              child: DropdownButtonFormField<String>(
                value: selectedCollege,
                items: colleges.map((college) {
                  return DropdownMenuItem(value: college, child: Text(college));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    controller.selectedCollege.value = value!;
                  });
                },

                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
                icon: const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Color(0xFF6E6E6E),
                  size: 30,
                ),
                menuMaxHeight: 150,
                dropdownColor: Colors.white,
                elevation: 2,
                style: const TextStyle(fontSize: 16, color: Color(0xFF494949)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 90),

            buildInputField(
              title: "NICKNAME",
              controller: controller.nameController,
              obscureText: false,
            ),
            //
            const SizedBox(height: 20),
            buildInputField(
              title: "ID",
              controller: controller.idController,
              obscureText: false,
            ),
            //
            const SizedBox(height: 20),
            buildInputField(
              title: "Password",
              controller: controller.pwController,
              obscureText: false,
              hintText: "영어 8글자 이상, 특수문자 하나 이상 포함",
            ),
            const SizedBox(height: 20),
            //
            buildInputField(
              title: "Birth",
              controller: controller.birthController,
              obscureText: false,
              hintText: "####.##.##",
            ),
            //
            const SizedBox(height: 20),

            buildCollegeField(),
            //
            const SizedBox(height: 20),
            buildInputField(
              title: "학과/학부",
              controller: controller.deptController,
              obscureText: false,
            ),
            Obx(() {
              final msg = controller.errorMessage.value;
              return msg.isEmpty
                  ? const SizedBox(height: 13)
                  : Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        msg,
                        style: const TextStyle(
                          color: Color(0xFFE94F4F),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFE94F4F),
                        ),
                      ),
                    );
            }),
            const SizedBox(height: 27),
            buildButton(
              button: "SIGN UP",
              onTap: () async {
                controller.signUp();
              },
            ),
          ],
        ),
      ),
    );
  }
}
