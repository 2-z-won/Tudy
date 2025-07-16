import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/LoginSignup/component.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({super.key});

  @override
  State<SingupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();

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
                    selectedCollege = value!;
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
              title: "NAME",
              controller: _nameController,
              obscureText: false,
            ),
            //
            const SizedBox(height: 20),
            buildInputButtonField(
              title: "NAME",
              controller: _idController,
              obscureText: false,
              button: "중복확인",
            ),
            //
            const SizedBox(height: 20),
            buildInputField(
              title: "Password",
              controller: _pwController,
              obscureText: false,
              hintText: "영어 8글자 이상, 특수문자 하나 이상 포함",
            ),
            const SizedBox(height: 20),
            //
            buildInputField(
              title: "Birth",
              controller: _birthController,
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
              controller: _deptController,
              obscureText: false,
            ),
            const SizedBox(height: 40),
            buildButton(
              button: "SIGN UP",
              onTap: () {
                Get.toNamed("/login");
              },
            ),
          ],
        ),
      ),
    );
  }
}
