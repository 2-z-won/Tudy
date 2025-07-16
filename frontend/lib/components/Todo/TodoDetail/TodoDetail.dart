import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/components/check.dart';

class TodoDetail extends StatelessWidget {
  final VoidCallback onClose;
  final String title; // ✅ 카테고리명
  final String group;
  final Color mainColor; // ✅ 메인색
  final Color subColor;
  final String certificationType;
  final String goalText; // ✅ 목표 내용
  final bool done; // ✅ 완료 여부

  const TodoDetail({
    super.key,
    required this.onClose,
    required this.title,
    required this.group,
    required this.mainColor,
    required this.subColor,
    required this.certificationType,
    required this.goalText,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      decoration: BoxDecoration(
        color: subColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 6, left: 10),
                decoration: BoxDecoration(
                  color: mainColor,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                "$title ($group)",
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '완료',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🔥 목표 🔥',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          goalText, // ✅ 전달 받은 목표 텍스트
                          style: const TextStyle(
                            fontSize: 13,
                            color: TextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✏️ 목표 달성 인증 방식',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      const SizedBox(height: 15),
                      if (certificationType == 'time') ...[
                        Row(
                          children: const [
                            SizedBox(width: 5),
                            CheckIcon(),
                            SizedBox(width: 7),
                            Text(
                              '시간 측정 ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '(최소 2시간 이상)',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const Center(
                          child: Text(
                            '00 h  :  00 m',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ] else if (certificationType == 'photo') ...[
                        Row(
                          children: const [
                            SizedBox(width: 5),
                            CheckIcon(),
                            SizedBox(width: 7),
                            Text(
                              '사진 인증',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                if (done) ...[
                  const Text(
                    "🍀 목표를 완료했어요 🍀",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ] else if (certificationType == 'time') ...[
                  const Text(
                    "🍀 목표 완료까지 ##h ##m 남았어요 🍀",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ] else if (certificationType == 'photo') ...[
                  const Text(
                    "🍀 사진을 찍어 목표 달성 인증 해주세요 🍀",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
