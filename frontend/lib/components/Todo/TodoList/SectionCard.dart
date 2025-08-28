import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

const _cardShadow = Color(0xFFF2E9DA);
BoxShadow get _dropShadow => const BoxShadow(
  color: _cardShadow, // 필요시 .withOpacity(0.6)
  offset: Offset(0, 0),
  blurRadius: 4,
  spreadRadius: 0,
);

class SectionCard extends StatelessWidget {
  final double height;
  final String title;
  final Widget child;

  final AlignmentGeometry contentAlignment;

  const SectionCard({
    super.key,
    required this.height,
    required this.title,
    required this.child,
    this.contentAlignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.5),
        boxShadow: [_dropShadow],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,

            child: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: "GmarketSans",
                  fontWeight: FontWeight.w700,
                  color: TextColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: contentAlignment, // ← 여기만 바뀜 (Center → Align)
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
