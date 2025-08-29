import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/money_controller.dart';

final MoneyController moneyController = Get.find();

class OddEvenGamePage extends StatefulWidget {
  const OddEvenGamePage({super.key});
  @override
  State<OddEvenGamePage> createState() => _OddEvenGamePageState();
}

class _OddEvenGamePageState extends State<OddEvenGamePage>
    with SingleTickerProviderStateMixin {
  final Random random = Random();
  final TextEditingController betController = TextEditingController(
    text: '100',
  );

  int remainingChances = 3;
  int? generatedNumber;
  bool _isFlipping = false;

  late final AnimationController _flipCtrl; // 카드 뒤집힘(0 -> pi)
  late final Animation<double> _angle;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _angle = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    betController.dispose();
    super.dispose();
  }

  void _changeBet(int delta) {
    final cur = int.tryParse(betController.text) ?? 0;
    final next = (cur + delta).clamp(0, moneyController.money.value);
    betController.text = next.toString();
  }

  Future<void> playGame(bool guessEven) async {
    if (_isFlipping) return;

    final bet = int.tryParse(betController.text);
    if (bet == null || bet <= 0) {
      _snack('⚠️ 올바른 배팅 금액을 입력하세요!');
      return;
    }
    if (bet > moneyController.money.value) {
      _snack('⚠️ 가진 돈보다 많이 걸 수 없어요!');
      return;
    }
    if (remainingChances <= 0) {
      _snack('😥 오늘은 더 이상 도전할 수 없어요..');
      return;
    }

    setState(() {
      _isFlipping = true;
      remainingChances--;
      generatedNumber = null; // 앞면(?)로 초기화
    });

    // 1~6 숫자 생성(주사위 감성)
    final number = random.nextInt(6) + 1;
    final isEven = number % 2 == 0;

    _flipCtrl.reset();
    // 뒤집힘 중간(> 90°)에 숫자 세팅
    _flipCtrl.addListener(() {
      if (_angle.value > pi / 2 && generatedNumber == null) {
        setState(() => generatedNumber = number);
      }
    });
    await _flipCtrl.forward();

    // 정산
    final win = (isEven == guessEven);
    if (win) {
      moneyController.addMoney(bet);
    } else {
      moneyController.subtractMoney(bet);
    }

    await _showResultDialog(
      title: win ? '🎉 정답!' : '❌ 오답!',
      message: '숫자는 $number • ${win ? '+' : '-'}₩$bet',
    );

    setState(() => _isFlipping = false);
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _showResultDialog({
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFEED9B7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: Text(title, style: const TextStyle(color: Color(0xFF3A2A1E))),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFF3A2A1E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: Color(0xFF3A2A1E))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF3A2A1E);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),
      body: Column(
        children: [
          PixelTopBar(
            title: '홀짝 게임', // 각 게임 제목
            useCloseIcon: true, // ← X 아이콘 사용
            onLeadingTap: () => Navigator.of(context).pop(), // 모달 닫기 → 메인으로
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _PixelPanel(
                // ← 심플 베이지 패널(로컬 데코)
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 남은 횟수
                    Text(
                      '남은 횟수: $remainingChances 회',
                      style: TextStyle(
                        color: remainingChances == 0 ? Colors.red : brown,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 베팅 + 스테퍼
                    Row(
                      children: [
                        const Text(
                          '베팅 ₩',
                          style: TextStyle(color: Color(0xFF3A2A1E)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: betController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StepperButton(
                          label: '−',
                          onTap: () => _changeBet(-100),
                        ),
                        const SizedBox(width: 4),
                        _StepperButton(
                          label: '+',
                          onTap: () => _changeBet(100),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ? 카드 (뒤집힘 애니)
                    SizedBox(
                      height: 160,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _angle,
                          builder: (context, _) {
                            final m = Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(_angle.value);
                            final showFront = _angle.value < pi / 2;

                            return Transform(
                              transform: m,
                              alignment: Alignment.center,
                              child: showFront
                                  ? const _MysteryCardFront()
                                  : Transform(
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      alignment: Alignment.center,
                                      child: _MysteryCardBack(
                                        text:
                                            generatedNumber?.toString() ?? '?',
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 버튼 (짝수 / 홀수)
                    Row(
                      children: [
                        Expanded(
                          child: PixelImageButton(
                            asset: 'images/ui/btn_red.png',
                            label: '짝수',
                            onTap: _isFlipping ? null : () => playGame(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PixelImageButton(
                            asset: 'images/ui/btn_blue.png',
                            label: '홀수',
                            onTap: _isFlipping ? null : () => playGame(false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 보유 금액
                    Obx(
                      () => Text(
                        '💰 보유 금액: ${moneyController.money.value} 원',
                        style: const TextStyle(fontSize: 16, color: brown),
                      ),
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

/* ---------------- 픽셀 카드(앞/뒤) ---------------- */

class _MysteryCardFront extends StatelessWidget {
  const _MysteryCardFront();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFEED9B7),
        border: Border.all(color: const Color(0xFF3A2A1E), width: 3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Color(0xFF3A2A1E),
          ),
        ),
      ),
    );
  }
}

class _MysteryCardBack extends StatelessWidget {
  final String text;
  const _MysteryCardBack({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF3C96B),
        border: Border.all(color: const Color(0xFF3A2A1E), width: 3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: Color(0xFF3A2A1E),
          ),
        ),
      ),
    );
  }
}

/* --------------- 커스텀 상단바/패널/버튼 --------------- */

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
            Obx(
              () => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '💰 ${moneyController.money.value}원',
                  style: const TextStyle(color: brown),
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

// 심플 베이지 박스(라운드+테두리)
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
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0xFFFFF3D9), offset: Offset(0, -1)),
          BoxShadow(color: Color(0xFFB38A6A), offset: Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

// 이미지 버튼(9-slice)
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
