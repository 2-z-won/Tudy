import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ─────────────────────────────────────────────
/// 신규 미니게임: 강의실 퀴즈
/// (곱셈/어휘/영어 카테고리 → 3라운드 객관식)
/// ─────────────────────────────────────────────

/// 카테고리
enum QuizCategory { multiply, vocab, english }

extension QuizCategoryX on QuizCategory {
  String get label => switch (this) {
    QuizCategory.multiply => '곱셈',
    QuizCategory.vocab => '어휘',
    QuizCategory.english => '영어',
  };

  /// 제한 시간(초)
  int get seconds => 4;

  /// 보기 버튼 기본색
  Color get color => switch (this) {
    QuizCategory.multiply => const Color(0xFF2141FF),
    QuizCategory.vocab => const Color(0xFFFF9100),
    QuizCategory.english => const Color(0xFFE53935),
  };
}

/// 결과 상태
enum QuizOutcome { none, success, fail }

/// 카테고리 선택 페이지
class ClassroomCategorySelectPage extends StatelessWidget {
  const ClassroomCategorySelectPage({super.key});

  TextStyle get _title => const TextStyle(
    fontFamily: 'Galmuri11',
    fontSize: 28,
    letterSpacing: 1.6,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('나가기'),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text('1,000'),
                ],
              ),
              const Spacer(),
              Text('강의실 GAME', style: _title),
              const SizedBox(height: 24),

              // 카테고리 버튼
              Wrap(
                spacing: 14,
                runSpacing: 12,
                children: QuizCategory.values.map((c) {
                  return _SquareButton(
                    label: c.label,
                    color: switch (c) {
                      QuizCategory.multiply => const Color(0xFF16C60C),
                      QuizCategory.vocab => const Color(0xFF2141FF),
                      QuizCategory.english => const Color(0xFFE53935),
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ClassroomGamePage(category: c),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

              const Spacer(),
              const SizedBox(height: 16),
              Text(
                '게임 설명 : 수업에 집중하던 참, 갑자기 교수님이 질문을 하셨다! '
                '제한 시간 내에 답을 해보자',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// 본게임 페이지
class ClassroomGamePage extends StatefulWidget {
  final QuizCategory category;
  const ClassroomGamePage({super.key, required this.category});

  @override
  State<ClassroomGamePage> createState() => _ClassroomGamePageState();
}

class _ClassroomGamePageState extends State<ClassroomGamePage> {
  static const int maxRounds = 3;
  final rng = Random();

  int round = 1;
  int successCount = 0;

  // 문제은행
  // question, options(3), correctIndex
  late final List<_QuizItem> bank = switch (widget.category) {
    QuizCategory.multiply => [
      _QuizItem('19 × 3 = ?', ['57', '47', '67'], 0),
      _QuizItem('12 × 4 = ?', ['36', '44', '48'], 2),
      _QuizItem('7 × 8 = ?', ['54', '56', '64'], 1),
      _QuizItem('9 × 6 = ?', ['54', '64', '45'], 0),
    ],
    QuizCategory.vocab => [
      _QuizItem('소가 방관하면 ?', ['소방관', '소웃음', '소보기'], 0),
      _QuizItem('눈이 녹으면 ?', ['물안경', '물', '안구건조'], 1),
      _QuizItem('바다가 화나면 ?', ['성난파도', '해분노', '바분노'], 0),
      _QuizItem('달이 아프면 ?', ['달고나', '달꿀', '달고프다'], 2),
    ],
    QuizCategory.english => [
      _QuizItem('elephant는 한국어로 ?', ['코뿔소', '코끼리', '송아지'], 1),
      _QuizItem('apple은 한국어로 ?', ['사과', '배', '포도'], 0),
      _QuizItem('teacher는 한국어로 ?', ['학생', '교사', '운동선수'], 1),
      _QuizItem('bird는 한국어로 ?', ['고양이', '개', '새'], 2),
    ],
  };

  // 현재 라운드 문제
  late _QuizItem current;
  List<String> choices = [];
  int? lockedIndex; // 정답/오답 눌린 버튼 index (잠금용)

  // 타이머
  Timer? ticker;
  DateTime? endAt;
  bool started = false;
  bool finishedRound = false;

  // 엔딩
  bool gameEnded = false;
  QuizOutcome outcome = QuizOutcome.none;
  String endBubbleText = '';
  String bottomMessage = '';

  @override
  void initState() {
    super.initState();
    _setupRound(first: true);
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  void _setupRound({bool first = false}) {
    ticker?.cancel();
    started = false;
    finishedRound = false;
    lockedIndex = null;

    if (first) {
      round = 1;
      successCount = 0;
      gameEnded = false;
      outcome = QuizOutcome.none;
      endBubbleText = '';
      bottomMessage = '';
    } else {
      outcome = QuizOutcome.none;
      endBubbleText = '';
      bottomMessage = '';
    }

    current = bank[rng.nextInt(bank.length)];
    choices = List<String>.from(current.options)..shuffle(rng);
    endAt = null;
    setState(() {});
  }

  double get timeLeft {
    if (endAt == null) return widget.category.seconds.toDouble();
    final left = endAt!.difference(DateTime.now()).inMilliseconds;
    return left <= 0 ? 0 : left / 1000.0;
  }

  void _start() {
    if (started || gameEnded) return;
    started = true;
    endAt = DateTime.now().add(Duration(seconds: widget.category.seconds));
    ticker = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return;
      if (finishedRound) {
        t.cancel();
        return;
      }
      if (timeLeft <= 0) {
        _finish(false, byTimeout: true);
        t.cancel();
        return;
      }
      setState(() {}); // 타이머 갱신
    });
    setState(() {});
  }

  void _finish(bool success, {bool byTimeout = false}) {
    if (finishedRound) return;
    finishedRound = true;
    started = false;
    ticker?.cancel();
    endAt = null;

    outcome = success ? QuizOutcome.success : QuizOutcome.fail;

    if (success) {
      successCount++;
      if (round == maxRounds) {
        gameEnded = true;
        endBubbleText = '정답! 모두 잘 풀었습니다. 수고했어요.';
        bottomMessage = '🎉 성공 🎉';
      }
    } else {
      gameEnded = true;
      endBubbleText = '아쉽지만 다음에 더 잘할 수 있어요!';
      bottomMessage = '😭 실패 😭';
      if (byTimeout) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('시간 초과!')));
      }
    }
    setState(() {});
  }

  void _tapChoice(int idx) {
    if (!started || finishedRound || gameEnded) return;
    final picked = choices[idx];
    final isCorrect = picked == current.options[current.correctIndex];
    lockedIndex = idx;
    _finish(isCorrect);
  }

  void _next() {
    if (gameEnded) return;
    if (round < maxRounds) {
      round++;
      _setupRound();
    }
  }

  Widget _timerCard() {
    final show = started && !finishedRound;
    final text = show ? '${timeLeft.toStringAsFixed(0)}초' : '';
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 3),
          borderRadius: BorderRadius.circular(0),
          image: const DecorationImage(
            image: AssetImage('assets/classroom.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Galmuri11',
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bubbleText = gameEnded ? endBubbleText : current.question;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('나가기'),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text('1,000'),
                ],
              ),
              const SizedBox(height: 8),
              _timerCard(),
              const SizedBox(height: 12),

              // 말풍선 + 캐릭터
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SpeechBubble(
                      text: bubbleText,
                      minHeight: 90,
                      maxWidthFraction: 0.72,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 96,
                    child: Image.asset(
                      'images/present.png',
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 보기/컨트롤
              if (!gameEnded) ...[
                if (started) ...[
                  Column(
                    children: List.generate(3, (i) {
                      final label = choices[i];
                      final disabled = finishedRound;
                      final bg = widget.category.color;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ChoiceButton(
                          label: label,
                          color: bg,
                          onTap: disabled ? null : () => _tapChoice(i),
                        ),
                      );
                    }),
                  ),
                ] else if (!finishedRound) ...[
                  Text(
                    '라운드 $round / $maxRounds  •  카테고리: ${widget.category.label}',
                    style: const TextStyle(
                      fontFamily: 'Galmuri11',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _start,
                          child: const Text(
                            'START',
                            style: TextStyle(
                              fontFamily: 'Galmuri11',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white38),
                            foregroundColor: Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _setupRound(first: true),
                          child: const Text(
                            '처음부터',
                            style: TextStyle(fontFamily: 'Galmuri11'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              const Spacer(),

              // 하단 결과표시
              if (gameEnded) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 150),
                  child: Text(
                    bottomMessage,
                    style: const TextStyle(
                      fontFamily: 'Galmuri11',
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ] else if (finishedRound) ...[
                Center(
                  child: Text(
                    '$round단계 ${successCount >= round ? "성공 !!" : "실패 .."}',
                    style: TextStyle(
                      fontFamily: 'Galmuri11',
                      fontSize: 28,
                      color: successCount >= round
                          ? Colors.white
                          : Colors.redAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _next,
                    child: const Text(
                      '>> NEXT >>',
                      style: TextStyle(fontFamily: 'Galmuri11'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 단순 사각 버튼
class _SquareButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SquareButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(0),
          boxShadow: const [BoxShadow(color: Colors.white12, blurRadius: 6)],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Galmuri11',
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// 보기 버튼
class _ChoiceButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ChoiceButton({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(0),
            boxShadow: const [BoxShadow(color: Colors.white12, blurRadius: 6)],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Galmuri11',
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// 말풍선 (기존 스타일 유지)
class _SpeechBubble extends StatelessWidget {
  final String text;
  final double minHeight;
  final double maxWidthFraction;
  const _SpeechBubble({
    required this.text,
    this.minHeight = 84,
    this.maxWidthFraction = 0.70,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, bc) {
        final maxW = (bc.maxWidth * maxWidthFraction).clamp(200, 360);
        return Align(
          alignment: Alignment.centerLeft,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: minHeight,
                    maxWidth: maxW.toDouble(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      text,
                      softWrap: true,
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.28,
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(right: -12, top: 18, child: _BubbleTail()),
            ],
          ),
        );
      },
    );
  }
}

class _BubbleTail extends StatelessWidget {
  const _BubbleTail({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(14, 14), painter: _BubbleTailPainter());
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 내부 문제 아이템 모델
class _QuizItem {
  final String question;
  final List<String> options;
  final int correctIndex;
  const _QuizItem(this.question, this.options, this.correctIndex);
}
