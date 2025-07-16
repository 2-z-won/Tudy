import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/LoginSignup/SingUpPage.dart';
import 'package:frontend/pages/LoginSignup/component.dart';

class SignUpEmailPage extends StatefulWidget {
  const SignUpEmailPage({super.key});

  @override
  State<SignUpEmailPage> createState() => _SignUpEmailPageState();
}

class _SignUpEmailPageState extends State<SignUpEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 150),
            const Center(
              child: Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFF595959),
                ),
              ),
            ),
            const SizedBox(height: 100),
            buildInputButtonField(
              title: "E-mail",
              controller: _emailController,
              obscureText: false,
              button: "전송",
              hintText: "####@pusan.ac.kr",
            ),
            const SizedBox(height: 15),
            buildInputField(
              title: "인증번호",
              controller: _numController,
              obscureText: false,
            ),
            SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                '인증번호가 틀렸습니다',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 10,
                  color: Color(0xFFE94F4F),
                ),
              ),
            ),

            const SizedBox(height: 30),
            buildButton(
              button: "Next",
              onTap: () {
                Get.toNamed("/signup");
              },
            ),
          ],
        ),
      ),
    );
  }
}
