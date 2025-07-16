import 'package:flutter/material.dart';
import 'package:frontend/pages/LoginSignup/component.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

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
                  //fontFamily: "Inter",
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFF595959),
                ),
              ),
            ),
            const SizedBox(height: 100),
            buildInputField(
              title: "ID",
              controller: _idController,
              obscureText: false,
            ),
            const SizedBox(height: 15),
            buildInputField(
              title: "Password",
              controller: _pwController,
              obscureText: true,
            ),
            const SizedBox(height: 13),
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
            buildButton(
              button: "LOGIN",
              onTap: () {
                Get.toNamed("/main");
              },
            ),
          ],
        ),
      ),
    );
  }
}
