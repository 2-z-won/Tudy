import 'package:flutter/material.dart';
import 'package:frontend/api/StopWatch/stopwatch_controller.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/components/check.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/api/Todo/controller/image_controller.dart';

class TodoDetail extends StatefulWidget {
  final VoidCallback onClose;
  final String category; // ✅ 카테고리명
  final String group;
  final Color mainColor; // ✅ 메인색
  final Color subColor;
  final String certificationType;
  final String goalText; // ✅ 목표 내용
  final bool done; // ✅ 완료 여부
  final int? targetTime; // 목표 시간(초)
  final int goalId;

  const TodoDetail({
    super.key,
    required this.onClose,
    required this.category,
    required this.group,
    required this.mainColor,
    required this.subColor,
    required this.certificationType,
    required this.goalText,
    required this.done,
    this.targetTime,
    required this.goalId,
  });

  @override
  State<TodoDetail> createState() => _TodoDetailState();
}

class _TodoDetailState extends State<TodoDetail> {
  final StudySessionController session = Get.put(StudySessionController());
  final GoalProofController proof = Get.put(GoalProofController());

  @override
  void initState() {
    super.initState();
    session.fetchAccumulatedTime(widget.goalId);
  }

  String _fmtHM(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}h ${m}m';
  }

  int _remainSeconds(int accumulated, int target) {
    final remain = target - accumulated;
    return remain > 0 ? remain : 0;
  }

  Future<void> _pickThenUpload() async {
    print('🔍 _pickThenUpload 함수 시작');
    print('🔍 widget.goalId: ${widget.goalId}');
    print('🔍 widget.certificationType: ${widget.certificationType}');
    print('🔍 widget.done: ${widget.done}');
    
    final picker = ImagePicker();
    print('🔍 ImagePicker 생성 완료');
    
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    print('🔍 이미지 선택 결과: ${img?.path ?? '선택 안됨'}');
    
    if (img == null) {
      print('🔍 이미지가 선택되지 않음');
      return;
    }

    print('🔍 이미지 업로드 시작: ${img.path}');
    final ok = await proof.uploadProofImage(
      goalId: widget.goalId,
      filePath: img.path,
    );
    print('🔍 이미지 업로드 결과: $ok');

    if (ok) {
      print('🔍 이미지 업로드 성공!');
      // 성공 시 닫고 부모가 리스트 갱신 (이미 구현됨)
      widget.onClose();
    } else if (mounted && proof.error.value != null) {
      print('🔍 이미지 업로드 실패: ${proof.error.value}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(proof.error.value!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 TodoDetail build 시작');
    print('🔍 widget.certificationType: ${widget.certificationType}');
    print('🔍 widget.done: ${widget.done}');
    print('🔍 widget.goalId: ${widget.goalId}');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      decoration: BoxDecoration(
        color: widget.subColor,
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
                  color: widget.mainColor,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                "${widget.category} (${widget.group})",
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onClose,
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
                          widget.goalText, // ✅ 전달 받은 목표 텍스트
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
                  width: double.infinity,
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
                      if (widget.certificationType == 'time') ...[
                        Row(
                          children: [
                            const SizedBox(width: 5),
                            const CheckIcon(),
                            const SizedBox(width: 5),
                            const Text(
                              '시간 측정 ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                '🎯 목표 시간',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                widget.targetTime != null
                                    ? '${widget.targetTime! ~/ 3600} h  ${(widget.targetTime! % 3600) ~/ 60} m'
                                    : '??h ??m',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Obx(() {
                                final accumulatedSeconds = session.accumulatedTime.value.inSeconds;
                                final targetSeconds = widget.targetTime ?? 0;
                                final remainingSeconds = _remainSeconds(accumulatedSeconds, targetSeconds);
                                
                                return Column(
                                  children: [
                                    Text(
                                      '⏱️ 누적 시간',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _fmtHM(accumulatedSeconds),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '⏳ 남은 시간',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _fmtHM(remainingSeconds),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: remainingSeconds > 0 ? Colors.orange : Colors.green,
                                      ),
                                    ),
                                    if (remainingSeconds == 0) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        '🎉 목표 달성!',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ] else if (widget.certificationType == 'photo' &&
                          widget.done) ...[
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
                      ] else if (widget.certificationType == 'photo' &&
                          !widget.done) ...[
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
                        const SizedBox(height: 13),
                        Obx(() {
                          print('🔍 사진 인증 버튼 Obx 실행');
                          print('🔍 proof.isUploading.value: ${proof.isUploading.value}');
                          
                          if (proof.isUploading.value) {
                            print('🔍 업로드 중 상태 - 로딩 UI 표시');
                            return Column(
                              children: const [
                                Center(
                                  child: Text(
                                    '〰️ 인증 중 〰️',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ],
                            );
                          }
                          print('🔍 업로드 완료 상태 - 사진 업로드 버튼 표시');
                          return Center(
                            child: GestureDetector(
                              onTap: () {
                                print('🔍 사진 업로드 버튼 터치됨!');
                                _pickThenUpload();
                              },
                              child: const Icon(Icons.add_a_photo, size: 24),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                if (widget.done) ...[
                  const Text(
                    "🍀 목표를 완료했어요 🍀",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ] else if (widget.certificationType == 'time') ...[
                  Obx(() {
                    final accSec = session.accumulatedTime.value.inSeconds;
                    final remain = _remainSeconds(accSec, widget.targetTime!);
                    return Text(
                      "🍀 목표 완료까지 ${_fmtHM(remain)} 남았어요 🍀",
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    );
                  }),
                ] else if (widget.certificationType == 'photo') ...[
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
