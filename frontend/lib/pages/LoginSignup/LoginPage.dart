import 'package:flutter/material.dart';
import 'package:frontend/api/SignupLogin/controller/login_controller.dart';
import 'package:frontend/pages/LoginSignup/component.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController controller = Get.put(LoginController());

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
                'TUDY',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: "GmarketSans",
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Color(0xFF595959),
                ),
              ),
            ),
            const SizedBox(height: 100),
            buildInputField(
              title: "ID",
              controller: controller.idController,
              obscureText: false,
            ),
            const SizedBox(height: 15),
            buildInputField(
              title: "Password",
              controller: controller.pwController,
              obscureText: true,
            ),
            // 에러 메시지 처리
            Obx(() {
              final hasError = controller.errorMessage.value.isNotEmpty;
              return Column(
                children: [
                  SizedBox(height: hasError ? 2 : 18),
                  if (hasError)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 10,
                          color: Color(0xFFE94F4F),
                          decorationColor: Color(0xFFE94F4F),
                        ),
                      ),
                    ),
                ],
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Get.toNamed("/signupEmail");
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                    color: Color(0xFF565656),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            buildButton(button: "LOGIN", onTap: controller.login),
          ],
        ),
      ),
    );
  }
}
