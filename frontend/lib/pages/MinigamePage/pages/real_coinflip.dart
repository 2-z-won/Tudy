import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/money_controller.dart';

final MoneyController moneyController = Get.find();

class CoinTossGamePage extends StatefulWidget {
  const CoinTossGamePage({super.key});
  @override
  State<CoinTossGamePage> createState() => _CoinTossGamePageState();
}

class _CoinTossGamePageState extends State<CoinTossGamePage>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  final TextEditingController _betCtrl = TextEditingController(text: '100');

  late final AnimationController _flipCtrl; // 0.9s 회전
  late final Animation<double> _angle;

  int _remaining = 3;
  bool _isFlipping = false;

  // 결과에 맞춰 최종 보이는 면을 정렬하는 기준 각도(앞:0, 뒤:pi)
  double _baseAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _angle =
        Tween<double>(begin: 0, end: pi * 4) // 네 바퀴
            .animate(
              CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
            );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _betCtrl.dispose();
    super.dispose();
  }

  void _changeBet(int delta) {
    final cur = int.tryParse(_betCtrl.text) ?? 0;
    final next = (cur + delta).clamp(0, moneyController.money.value);
    _betCtrl.text = next.toString();
  }

  Future<void> _play(bool guessHeads) async {
    if (_isFlipping) return;

    final bet = int.tryParse(_betCtrl.text) ?? 0;
    if (bet <= 0) {
      _showSnack('⚠️ 올바른 배팅 금액을 입력하세요!');
      return;
    }
    if (bet > moneyController.money.value) {
      _showSnack('⚠️ 가진 돈보다 많이 걸 수 없어요!');
      return;
    }
    if (_remaining <= 0) {
      _showSnack('😥 오늘은 더 이상 도전할 수 없어요..');
      return;
    }

    setState(() {
      _isFlipping = true;
      _remaining--;
    });

    // 결과
    final isHeads = _random.nextBool();
    setState(() => _baseAngle = isHeads ? 0.0 : pi);

    // 회전
    await _flipCtrl.forward(from: 0);

    // 정산
    final win = (isHeads == guessHeads);
    if (win) {
      moneyController.addMoney(bet);
    } else {
      moneyController.subtractMoney(bet);
    }

    final label = isHeads ? '앞면' : '뒷면';
    await _showResultDialog(
      title: win ? '🐤 승리!' : '😵 패배!',
      message: '$label! ${win ? '+' : '-'}₩$bet',
    );

    setState(() => _isFlipping = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

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
            title: '동전 앞뒤 게임', // 각 게임 제목
            useCloseIcon: true, // ← X 아이콘 사용
            onLeadingTap: () => Navigator.of(context).pop(), // 모달 닫기 → 메인으로
          ),

          // 본문
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _PixelPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '남은 횟수: $_remaining 회',
                      style: TextStyle(
                        color: _remaining == 0 ? Colors.red : brown,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 베팅 입력 + 스테퍼
                    Row(
                      children: [
                        const Text(
                          '베팅 ₩',
                          style: TextStyle(color: Color(0xFF3A2A1E)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _betCtrl,
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

                    // 코인(회전)
                    SizedBox(
                      height: 150,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _angle,
                          builder: (context, child) {
                            final m = Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(_angle.value + _baseAngle);
                            final v = (_angle.value + _baseAngle) % (2 * pi);
                            final showFront = v < pi;
                            return Transform(
                              transform: m,
                              alignment: Alignment.center,
                              child: showFront
                                  ? const _CoinFace(label: '앞')
                                  : Transform(
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      alignment: Alignment.center,
                                      child: const _CoinFace(label: '뒤'),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 이미지 버튼(앞/뒤)
                    Row(
                      children: [
                        Expanded(
                          child: PixelImageButton(
                            asset: 'images/ui/btn_red.png',
                            label: '앞면',
                            onTap: _isFlipping ? null : () => _play(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PixelImageButton(
                            asset: 'images/ui/btn_blue.png',
                            label: '뒷면',
                            onTap: _isFlipping ? null : () => _play(false),
                          ),
                        ),
                      ],
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

/* ---------- 커스텀 상단바 ---------- */

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

/// PNG 배경을 9-slice(centerSlice)로 늘리는 픽셀 이미지 버튼.
/// (원본이 83x34px 기준. 다르면 Rect 숫자를 원본에 맞게 조정하세요.)
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
    this.height = 44,
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
                  centerSlice: const Rect.fromLTWH(12, 12, 59, 10),
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
            borderRadius: BorderRadius.circular(4),
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

class _CoinFace extends StatelessWidget {
  final String label; // '앞' or '뒤'
  const _CoinFace({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF3C96B),
        border: Border.all(color: const Color(0xFF3A2A1E), width: 3),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Color(0xFF3A2A1E),
          ),
        ),
      ),
    );
  }
}
