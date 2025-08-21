import 'package:flutter/material.dart';
import 'package:frontend/components/check.dart';

const _cardShadow = Color(0xFFF2E9DA);

BoxShadow get dropShadow => const BoxShadow(
  color: _cardShadow, // 필요시 .withOpacity(0.6)
  offset: Offset(0, 0),
  blurRadius: 4,
  spreadRadius: 0,
);

Widget buildTypeOption({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      children: [
        isSelected ? const CheckIcon() : const NoCheckIcon(),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    ),
  );
}

class CompleteButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const CompleteButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: color,
          boxShadow: [
            BoxShadow(
              color: _cardShadow, // 필요시 .withOpacity(0.6)
              offset: Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: "GmarketSans",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
