import 'package:flutter/material.dart';
import 'package:frontend/api/SignupLogin/controller/email_verify_controller.dart';
import 'package:frontend/constants/colors.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/LoginSignup/component.dart';

class SignUpEmailPage extends StatefulWidget {
  const SignUpEmailPage({super.key});

  @override
  State<SignUpEmailPage> createState() => _SignUpEmailPageState();
}

class _SignUpEmailPageState extends State<SignUpEmailPage> {
  final EmailVerifyController _verifyController = Get.put(
    EmailVerifyController(),
  );

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
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
                  onTap: () {
                    _verifyController.sendCode(_emailController.text.trim());
                  },
                ),
                const SizedBox(height: 15),
                buildInputField(
                  title: "인증번호",
                  controller: _numController,
                  obscureText: false,
                ),
                SizedBox(height: 2),

                Obx(() {
                  if (_verifyController.errorMessage.value.isNotEmpty) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          _verifyController.errorMessage.value,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFE94F4F),
                            fontSize: 10,
                            color: Color(0xFFE94F4F),
                          ),
                        ),
                      ),
                    );
                  } else if (_verifyController
                      .successMessage
                      .value
                      .isNotEmpty) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          _verifyController.successMessage.value,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: SubTextColor,
                            fontSize: 10,
                            color: SubTextColor, // 검정색
                          ),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(height: 13); // 빈 공간 유지
                  }
                }),

                const SizedBox(height: 30),
                buildButton(
                  button: "Next",
                  onTap: () async {
                    await _verifyController.verifyEmail(
                      _emailController.text.trim(),
                      _numController.text.trim(),
                    );
                    if (_verifyController.isVerified.value) {
                      Get.toNamed(
                        '/signup',
                        arguments: _emailController.text.trim(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 15,
            left: 15,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: SubTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
