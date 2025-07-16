import 'package:flutter/material.dart';

class CheckIcon extends StatelessWidget {
  const CheckIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: const Color(0xFFFF4A4A),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 15 * 0.9, // 아이콘 크기를 컨테이너 크기에 맞게
        ),
      ),
    );
  }
}

class NoCheckIcon extends StatelessWidget {
  const NoCheckIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Color(0xFFFF4A4A), width: 1),
      ),
    );
  }
}
