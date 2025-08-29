import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import '../controller/money_controller.dart';

final MoneyController moneyController = Get.find();

class UpDownGamePage extends StatefulWidget {
  const UpDownGamePage({super.key});

  @override
  State<UpDownGamePage> createState() => _UpDownGamePageState();
}

class _UpDownGamePageState extends State<UpDownGamePage> {
  final Random random = Random();

  // 입력 컨트롤러
  final TextEditingController guessController = TextEditingController();
  final TextEditingController betController = TextEditingController(
    text: '100',
  );

  // 상태
  int currentTry = 0; // 0~6
  int? targetNumber; // 1~100
  int? currentBet; // 라운드 고정 배팅
  String result = ""; // 힌트/결과 메시지
  bool _inGame = false; // 라운드 진행 중 여부

  // 시도 기록
  final List<_Attempt> _history = [];

  @override
  void dispose() {
    guessController.dispose();
    betController.dispose();
    super.dispose();
  }

  // ======== 게임 흐름 ========

  // 베팅 검증 후 라운드 시작
  void _startGame() {
    final bet = int.tryParse(betController.text);
    if (bet == null || bet <= 0) {
      _snack('⚠️ 베팅 금액을 올바르게 입력하세요!');
      return;
    }
    if (bet > moneyController.money.value) {
      _snack('⚠️ 가진 돈보다 많이 걸 수 없어요!');
      return;
    }

    setState(() {
      currentBet = bet; // 베팅 확정
      targetNumber = random.nextInt(100) + 1;
      currentTry = 0;
      result = "🎯 1~100 사이 숫자 생성! 1~5회는 힌트, 6회차에 정답 판정해요.";
      guessController.text = "";
      _history.clear();
      _inGame = true; // UI 전환
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("난수가 생성되었습니다! (시도 0 / 6)")));
  }

  // 정답 제출(1~5 힌트, 6 정산)
  void playGame() {
    final guess = int.tryParse(guessController.text);

    if (!_inGame || targetNumber == null) {
      setState(() => result = "🎯 먼저 '게임 시작'을 해주세요!");
      return;
    }
    if (currentBet == null) {
      setState(() => result = "💸 베팅 금액이 설정되지 않았어요.");
      return;
    }
    if (currentTry >= 6) {
      setState(() => result = "😥 이미 게임이 끝났어요! 다시 시작하세요.");
      return;
    }
    if (guess == null || guess < 1 || guess > 100) {
      setState(() => result = "⚠️ 1부터 100 사이의 숫자를 입력하세요!");
      return;
    }

    setState(() {
      currentTry++;

      if (currentTry < 6) {
        if (guess > targetNumber!) {
          _history.add(_Attempt(guess, _Dir.down));
          result = "💡 힌트: DOWN 🔽 (시도 $currentTry / 6)";
        } else if (guess < targetNumber!) {
          _history.add(_Attempt(guess, _Dir.up));
          result = "💡 힌트: UP 🔼 (시도 $currentTry / 6)";
        } else {
          _history.add(_Attempt(guess, _Dir.equal));
          result = "🤫 정답 같아요! (판정은 6회차) (시도 $currentTry / 6)";
        }
      } else {
        final correct = (guess == targetNumber);
        _history.add(
          _Attempt(
            guess,
            correct
                ? _Dir.equal
                : (guess > targetNumber! ? _Dir.down : _Dir.up),
          ),
        );

        if (correct) {
          moneyController.addMoney(currentBet!);
          result = "🎉 정답! 숫자는 $targetNumber ➕ $currentBet원 획득!";
        } else {
          moneyController.subtractMoney(currentBet!);
          result = "❌ 틀렸어요! 정답은 $targetNumber ➖ $currentBet원 차감!";
        }

        // 라운드 종료 → UI 초기화
        targetNumber = null;
        currentBet = null;
        _inGame = false; // 👉 추측/제출 UI 숨김
      }

      guessController.clear();
    });
  }

  // ======== 헬퍼 ========

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _bumpGuess(int delta) {
    final cur = int.tryParse(guessController.text) ?? 50;
    final next = (cur + delta).clamp(1, 100);
    setState(() => guessController.text = next.toString());
  }

  void _bumpBet(int delta) {
    final cur = int.tryParse(betController.text) ?? 0;
    final max = moneyController.money.value;
    final next = (cur + delta).clamp(0, max);
    setState(() => betController.text = next.toString());
  }

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF3A2A1E);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),
      body: Column(
        children: [
          PixelTopBar(
            title: '업다운 게임', // 각 게임 제목
            useCloseIcon: true, // ← X 아이콘 사용
            onLeadingTap: () => Navigator.of(context).pop(), // 모달 닫기 → 메인으로
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _PixelPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ===== 베팅 입력 (항상 보이되, 게임 중엔 잠금) =====
                    Row(
                      children: [
                        const Text('베팅 ₩', style: TextStyle(color: brown)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: betController,
                            enabled: !_inGame, // 라운드 중 잠금
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StepperButton(
                          label: '−',
                          onTap: !_inGame ? () => _bumpBet(-100) : () {},
                        ),
                        const SizedBox(width: 4),
                        _StepperButton(
                          label: '+',
                          onTap: !_inGame ? () => _bumpBet(100) : () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ===== 게임 시작 버튼 (라운드 중에는 숨김) =====
                    if (!_inGame)
                      PixelImageButton(
                        asset: 'images/ui/btn_red.png',
                        label: '게임 시작',
                        onTap: _startGame,
                        height: 48,
                      ),

                    const SizedBox(height: 16),

                    // ===== 추측 & 정답 제출 (라운드 시작 후에만 표시) =====
                    if (_inGame) ...[
                      Row(
                        children: [
                          const Text('추측', style: TextStyle(color: brown)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: guessController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                labelText: "1~100",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StepperButton(
                            label: '−',
                            onTap: () => _bumpGuess(-1),
                          ),
                          const SizedBox(width: 4),
                          _StepperButton(
                            label: '+',
                            onTap: () => _bumpGuess(1),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      PixelImageButton(
                        asset: 'images/ui/btn_green.png',
                        label: '정답 제출',
                        onTap: playGame,
                        height: 48,
                      ),
                    ],

                    const SizedBox(height: 14),

                    // 기록 칩
                    if (_history.isNotEmpty) ...[
                      const Text(
                        '기록',
                        style: TextStyle(
                          color: brown,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _history
                            .map((a) => _AttemptChip(attempt: a))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // 결과/힌트
                    if (result.isNotEmpty)
                      Text(
                        result,
                        style: const TextStyle(fontSize: 16, color: brown),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------- 시도 기록 모델/칩 ---------- */

enum _Dir { up, down, equal }

class _Attempt {
  final int value;
  final _Dir dir;
  _Attempt(this.value, this.dir);
}

class _AttemptChip extends StatelessWidget {
  const _AttemptChip({required this.attempt});
  final _Attempt attempt;

  Color get _border {
    switch (attempt.dir) {
      case _Dir.up:
        return const Color(0xFF5A86B6);
      case _Dir.down:
        return const Color(0xFFB45842);
      case _Dir.equal:
        return const Color(0xFF6DB05E);
    }
  }

  String get _mark {
    switch (attempt.dir) {
      case _Dir.up:
        return '↑';
      case _Dir.down:
        return '↓';
      case _Dir.equal:
        return '✓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _border.withOpacity(0.15),
        border: Border.all(color: _border, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${attempt.value} $_mark',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/* ---------- 공용 픽셀 UI ---------- */

class PixelTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onLeadingTap;
  final bool useCloseIcon; // true면 X, false면 ←

  const PixelTopBar({
    super.key,
    required this.title,
    this.onLeadingTap,
    this.useCloseIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF3A2A1E);
    const beige = Color(0xFFEED9B7);

    return SafeArea(
      bottom: false,
      child: Container(
        height: kToolbarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: beige,
          border: Border(
            bottom: BorderSide(color: Color(0xFFB38A6A), width: 1),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onLeadingTap,
              icon: Icon(useCloseIcon ? Icons.close : Icons.arrow_back),
              color: brown,
              splashRadius: 22,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: brown,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 40), // 좌우 균형
          ],
        ),
      ),
    );
  }
}

/* ---------- 재사용 픽셀 UI 조각 ---------- */

class _PixelPanel extends StatelessWidget {
  final Widget child;
  const _PixelPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEED9B7),
        border: Border.all(color: const Color(0xFF3A2A1E), width: 1),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Color(0xFFFFF3D9), offset: Offset(0, -1)),
          BoxShadow(color: Color(0xFFB38A6A), offset: Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

class PixelImageButton extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback? onTap;
  final double height;
  final TextStyle? textStyle;

  const PixelImageButton({
    super.key,
    required this.asset,
    required this.label,
    this.onTap,
    this.height = 48,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  asset,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                  isAntiAlias: false,
                  centerSlice: const Rect.fromLTWH(12, 12, 59, 10), // 83x34 기준
                ),
                Center(
                  child: Text(
                    label,
                    style:
                        textStyle ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _StepperButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEED9B7),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF3A2A1E)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF3A2A1E),
            ),
          ),
        ),
      ),
    );
  }
}
