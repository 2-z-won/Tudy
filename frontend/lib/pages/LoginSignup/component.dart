import 'package:flutter/material.dart';

Widget buildInputField({
  required title,
  required TextEditingController controller,
  required bool obscureText,
  String hintText = '',
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsetsGeometry.only(left: 7, bottom: 1),
        child: Text(
          title,
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 16, color: Color(0xFF494949)),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: hintText.isNotEmpty
                ? const TextStyle(fontSize: 16, color: Color(0xFFCECECE))
                : null,
          ),
        ),
      ),
    ],
  );
}

Widget buildInputButtonField({
  required title,
  required TextEditingController controller,
  required bool obscureText,
  required button,
  String hintText = '',
  void Function()? onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsetsGeometry.only(left: 7, bottom: 1),
        child: Text(
          title,
          style: TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
        ),
      ),
      Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE1DDD4), width: 2),
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                style: const TextStyle(fontSize: 14, color: Color(0xFF494949)),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: hintText.isNotEmpty
                      ? const TextStyle(fontSize: 14, color: Color(0xFFCECECE))
                      : null,
                ),
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE1DDD4), width: 2),
                  color: Color(0xFFFFF6E5),
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Text(
                    button,
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.1,
                      color: Color(0xFF565656),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget buildButton({
  required String button,
  required VoidCallback onTap, // 클릭 시 실행할 함수
}) {
  return GestureDetector(
    onTap: onTap, // 클릭 이벤트 처리
    child: Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E5),
        border: Border.all(color: const Color(0xFFE1DDD4), width: 2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Text(
          button,
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF6E6E6E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
