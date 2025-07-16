import 'package:flutter/material.dart';

class JoinAddField extends StatelessWidget {
  final String hinttext;
  final String button;
  final TextEditingController controller;
  final VoidCallback onJoin;

  const JoinAddField({
    super.key,
    required this.hinttext,
    required this.button,
    required this.controller,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE1DDD4)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Color(0xFFEDEDED),
                border: Border.all(color: Color(0xFFE1DDD4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: controller,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: hinttext,
                  hintStyle: TextStyle(color: Color(0xFFA6A6A6), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onJoin,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFFFFF6E5),
                border: Border.all(color: Color(0xFFE1DDD4)),
              ),
              child: Text(
                button,
                style: TextStyle(
                  color: Color(0xFF565656),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
