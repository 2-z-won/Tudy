import 'package:flutter/material.dart';

class JoinRequestRow extends StatelessWidget {
  final String name;
  final String imageAsset;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const JoinRequestRow({
    super.key,
    required this.name,
    required this.imageAsset,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFE1DDD4)),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Image.asset(imageAsset),
        ),
        const SizedBox(width: 10),
        Text(name, style: TextStyle(fontSize: 13, color: Colors.black)),
        const Spacer(),
        GestureDetector(
          onTap: onApprove,
          child: Text(
            "승인",
            style: TextStyle(fontSize: 10, color: Colors.black),
          ),
        ),
        Text("  |  ", style: TextStyle(fontSize: 10, color: Colors.black)),
        GestureDetector(
          onTap: onReject,
          child: Text(
            "거부",
            style: TextStyle(fontSize: 10, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class GoalItem extends StatelessWidget {
  final String text;
  final bool isDone;

  const GoalItem({super.key, required this.text, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 5),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFF595959),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.black),
            ),
          ),
          Text(
            isDone ? "(완료)" : "(미완료)",
            style: TextStyle(fontSize: 10, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
