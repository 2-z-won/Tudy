import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SeminarGameApp extends StatelessWidget {
  const SeminarGameApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorSchemeSeed: Colors.purple,
      textTheme: const TextTheme(bodyMedium: TextStyle(letterSpacing: 0.5)),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const LevelSelectPage(),
    );
  }
}

// ────────────────────────────────────────────────────
// 난이도
enum Difficulty { beginner, intermediate, advanced }

extension DifficultyX on Difficulty {
  String get label => switch (this) {
    Difficulty.beginner => '초보',
    Difficulty.intermediate => '중수',
    Difficulty.advanced => '고수',
  };
  int get seconds => switch (this) {
    Difficulty.beginner => 15,
    Difficulty.intermediate => 10,
    Difficulty.advanced => 7,
  };
  Color get color => switch (this) {
    Difficulty.beginner => const Color(0xFF16C60C),
    Difficulty.intermediate => const Color(0xFF2141FF),
    Difficulty.advanced => const Color(0xFFE53935),
  };
}

// 엔딩 상태
enum RoundOutcome { none, success, fail }

// ────────────────────────────────────────────────────
// 1) 난이도 선택
class LevelSelectPage extends StatelessWidget {
  const LevelSelectPage({super.key});

  TextStyle get _titleStyle => const TextStyle(
    fontFamily: 'Galmuri11',
    fontSize: 28,
    letterSpacing: 2.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () {},
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
              Text(
                '세미나실 GAME',
                style: _titleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                children: Difficulty.values.map((d) {
                  return _LevelButton(
                    label: d.label,
                    color: d.color,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LevelIntroPage(difficulty: d),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              const SizedBox(height: 16),
              const _GameDescription(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _LevelButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(0), // ✅ 각진 버튼
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

class _GameDescription extends StatelessWidget {
  const _GameDescription();
  @override
  Widget build(BuildContext context) {
    return Text(
      '게임 설명 : 오늘은 세미나실에서 프로젝트 발표가 있는 날이다! '
      '발표자가 발표를 무사히 마칠 수 있게 말을 완성해주자',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white.withOpacity(0.9)),
    );
  }
}

// ────────────────────────────────────────────────────
// 2) 레벨 인트로 (START 화면)
class LevelIntroPage extends StatelessWidget {
  final Difficulty difficulty;
  const LevelIntroPage({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final title = '세미나실 GAME - ${difficulty.label}';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
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
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Galmuri11',
                  fontSize: 24,
                  letterSpacing: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 160,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0), // ✅ 각진 버튼
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => GamePage(difficulty: difficulty),
                      ),
                    );
                  },
                  child: const Text(
                    'START',
                    style: TextStyle(
                      fontFamily: 'Galmuri11',
                      fontSize: 20,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const _GameDescription(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────
// 3) 게임 플레이 (엔딩도 동일 페이지에서 표시)
class GamePage extends StatefulWidget {
  final Difficulty difficulty;
  const GamePage({super.key, required this.difficulty});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const int maxRounds = 3;
  final rng = Random();

  int round = 1;
  int successCount = 0;

  final List<List<String>> phraseSets = const [
    ["오늘의", "발표는", "순서대로", "진행하도록", "하겠습니다"],
    ["먼저", "목차를", "소개하고", "발표를", "시작하겠습니다"],
    ["조사한", "내용을", "간단히", "설명드리겠습니다"],
    ["이어서", "연구", "방법과", "결과를", "말씀드리겠습니다"],
  ];
  late List<String> correctOrder;
  late List<String> pool;
  final Set<int> locked = {};
  int expecting = 0;

  // 타이머
  Timer? ticker;
  DateTime? endAt;
  bool started = false;
  bool roundFinished = false;

  // 엔딩 상태
  bool gameEnded = false; // 전체 게임 종료 여부
  RoundOutcome lastOutcome = RoundOutcome.none;
  String endBubbleText = ''; // 엔딩 말풍선 텍스트
  String bottomMessage = ''; // 하단 큰 텍스트(🎉 성공 / 😭 실패)

  String get composed => correctOrder.take(expecting).join(' ');

  @override
  void initState() {
    super.initState();
    _setupRound(fresh: true);
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  void _setupRound({bool fresh = false}) {
    ticker?.cancel();
    started = false;
    roundFinished = false;
    expecting = 0;
    locked.clear();

    if (fresh) {
      round = 1;
      successCount = 0;
      gameEnded = false;
      lastOutcome = RoundOutcome.none;
      endBubbleText = '';
      bottomMessage = '';
    } else {
      lastOutcome = RoundOutcome.none;
      endBubbleText = '';
      bottomMessage = '';
    }

    correctOrder = List<String>.from(
      phraseSets[rng.nextInt(phraseSets.length)],
    );
    pool = List<String>.from(correctOrder)..shuffle(rng);
    endAt = null;
    setState(() {});
  }

  double get timeLeft {
    if (endAt == null) return widget.difficulty.seconds.toDouble();
    final leftMs = endAt!.difference(DateTime.now()).inMilliseconds;
    return leftMs <= 0 ? 0.0 : leftMs / 1000.0;
  }

  void _startRound() {
    if (started || gameEnded) return;
    started = true;
    endAt = DateTime.now().add(Duration(seconds: widget.difficulty.seconds));
    ticker = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return;
      if (roundFinished) {
        t.cancel();
        return;
      }
      if (timeLeft <= 0) {
        _finishRound(false, byTimeout: true);
        t.cancel();
        return;
      }
      setState(() {});
    });
    setState(() {});
  }

  void _finishRound(bool success, {bool byTimeout = false}) {
    if (roundFinished) return;
    roundFinished = true;
    started = false;
    ticker?.cancel();
    endAt = null;

    lastOutcome = success ? RoundOutcome.success : RoundOutcome.fail;

    if (success) {
      successCount++;
      if (round == maxRounds) {
        gameEnded = true;
        endBubbleText = '오늘의 발표를 무사히 잘 끝냈습니다. 감사합니다.';
        bottomMessage = '🎉 성공 🎉';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '라운드 $round 성공! 남은 시간: ${timeLeft.toStringAsFixed(1)}초',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      gameEnded = true;
      endBubbleText = '다음에는 더 잘할 수 있을 거예요 화이팅 !';
      bottomMessage = '😭 실패 😭';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            byTimeout ? '시간 초과! 라운드 $round 실패' : '오답! 라운드 $round 실패',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {});
  }

  void _tapToken(int i) {
    if (!started || roundFinished || gameEnded) return;
    if (locked.contains(i)) return;

    final token = pool[i];
    final expected = correctOrder[expecting];

    if (token == expected) {
      setState(() {
        locked.add(i);
        expecting++;
      });
      if (expecting == correctOrder.length) _finishRound(true);
    } else {
      _finishRound(false);
    }
  }

  void _next() {
    if (gameEnded) return;
    if (round < maxRounds) {
      round++;
      _setupRound();
    }
  }

  Widget _timerCard() {
    final bool showTime = started && !roundFinished;
    final String display = showTime ? '${timeLeft.toStringAsFixed(0)}초' : '';
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 3),
          borderRadius: BorderRadius.circular(0), // ✅ 각진
          image: const DecorationImage(
            image: AssetImage('assets/classroom.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text(
            display,
            style: const TextStyle(fontFamily: 'Galmuri11', fontSize: 32),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.difficulty;
    final bool showEndingBubble = gameEnded;
    final String bubbleText = showEndingBubble ? endBubbleText : composed;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
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

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SpeechBubble(
                      text: bubbleText,
                      minHeight: 96,
                      maxWidthFraction: 0.72,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 96,
                    child: Image.asset(
                      'assets/images/present.png',
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (!gameEnded) ...[
                if (started) ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(pool.length, (i) {
                      final disabled = locked.contains(i) || roundFinished;
                      return _TokenButton(
                        label: pool[i],
                        color: [
                          const Color(0xFF2141FF),
                          const Color(0xFFFF9100),
                          const Color(0xFF16C60C),
                          const Color(0xFFE53935),
                          const Color(0xFF8E24AA),
                        ][i % 5],
                        onTap: disabled ? null : () => _tapToken(i),
                      );
                    }),
                  ),
                ] else if (!roundFinished) ...[
                  const SizedBox(height: 8),
                  Text(
                    '라운드 $round / $maxRounds  •  난이도: ${d.label}',
                    style: const TextStyle(fontFamily: 'Galmuri11'),
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
                              borderRadius: BorderRadius.circular(0), // ✅ 각진
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _startRound,
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
                              borderRadius: BorderRadius.circular(0), // ✅ 각진
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _setupRound,
                          child: const Text(
                            '라운드 다시하기',
                            style: TextStyle(fontFamily: 'Galmuri11'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              const Spacer(),

              if (gameEnded) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 150),
                  child: Text(
                    bottomMessage,
                    style: const TextStyle(
                      fontFamily: 'Galmuri11',
                      fontSize: 32,
                    ),
                  ),
                ),
              ] else if (roundFinished) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 150),
                  child: Text(
                    '${round} ${successCount >= round ? "성공 !!" : "실패 .."}',
                    style: TextStyle(
                      fontFamily: 'Galmuri11',
                      fontSize: 28,
                      color: successCount >= round
                          ? Colors.white
                          : Colors.redAccent,
                    ),
                  ),
                ),
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

// ────────────────────────────────────────────────────
// 말풍선
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
                      text.isEmpty ? '' : text,
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

// ────────────────────────────────────────────────────
// 토큰 버튼
class _TokenButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _TokenButton({required this.label, required this.color, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(0), // ✅ 각진
            boxShadow: const [BoxShadow(color: Colors.white12, blurRadius: 6)],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Galmuri11',
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
