import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GymGameApp extends StatelessWidget {
  const GymGameApp({super.key});
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
      home: const GymIntroPage(),
    );
  }
}

/// ─────────────────────────────────────────────────
/// 공통: 상단바
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('나가기'),
        ),
        const Spacer(),
        const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
        const SizedBox(width: 6),
        const Text('1,000'),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────
/// 페이지 1: START
class GymIntroPage extends StatelessWidget {
  const GymIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _TopBar(),
              const Spacer(),
              const Text(
                '헬스장 GAME',
                style: TextStyle(
                  fontFamily: 'Galmuri11',
                  fontSize: 28,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GymCatchPage()),
                    );
                  },
                  child: const Text(
                    'START',
                    style: TextStyle(fontFamily: 'Galmuri11', fontSize: 22),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '게임 설명 : 운동을 해야하지만 맛있는 야식이 땡긴다! '
                '그래도 참고 운동을 해야지...\n떨어지는 야식들은 피하고, 덤벨만 담아보자',
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

/// ─────────────────────────────────────────────────
/// 떨어지는 아이템 정의
enum DropType { dumbbell, beer, cola, chicken }

class DropItem {
  DropItem({
    required this.type,
    required this.x, // 0~1 (화면 비율)
    required this.y, // 0~1
    required this.size, // 화면 너비 기준 비율
    required this.speed, // 0~1/초 (y 증가 속도)
  });

  final DropType type;
  double x;
  double y;
  double size;
  double speed;

  bool get isBad =>
      type == DropType.beer ||
      type == DropType.cola ||
      type == DropType.chicken;
}

/// ─────────────────────────────────────────────────
/// 페이지 2: 플레이
class GymCatchPage extends StatefulWidget {
  const GymCatchPage({super.key});

  @override
  State<GymCatchPage> createState() => _GymCatchPageState();
}

class _GymCatchPageState extends State<GymCatchPage> {
  final rng = Random();

  DateTime? startAt; // 시작 시간 기록
  Timer? tick;
  Timer? spawner;

  int score = 0;
  bool over = false;

  double basketX = 0.5;
  static const double basketWidthRatio = 0.26;
  static const double basketHeightRatio = 0.035;

  final List<DropItem> items = [];
  Size? lastSize;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    tick?.cancel();
    spawner?.cancel();
    super.dispose();
  }

  void _startGame() {
    score = 0;
    over = false;
    items.clear();
    startAt = DateTime.now();

    tick = Timer.periodic(const Duration(milliseconds: 16), (_) => _update());
    spawner = Timer.periodic(
      const Duration(milliseconds: 650),
      (_) => _spawn(),
    );
    setState(() {});
  }

  void _endGame() {
    if (over) return;
    over = true;
    tick?.cancel();
    spawner?.cancel();

    Future.microtask(() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GymResultPage(score: score)),
      );
    });
  }

  // 아이템 스폰
  void _spawn() {
    if (over) return;

    final elapsed = DateTime.now().difference(startAt!).inSeconds;
    final level = (elapsed ~/ 4); // 4초마다 속도 증가

    double baseMin = 0.25;
    double baseMax = 0.70;
    baseMin += level * 0.05;
    baseMax += level * 0.05;

    final speed = baseMin + rng.nextDouble() * (baseMax - baseMin);

    final r = rng.nextDouble();
    final type = r < 0.60
        ? DropType.dumbbell
        : (r < 0.75
              ? DropType.beer
              : (r < 0.87 ? DropType.cola : DropType.chicken));

    items.add(
      DropItem(
        type: type,
        x: rng.nextDouble().clamp(0.08, 0.92),
        y: -0.08,
        size: 0.08 + rng.nextDouble() * 0.03,
        speed: speed,
      ),
    );
  }

  void _update() {
    if (!mounted || over) return;

    for (final it in items) {
      it.y += it.speed * (16 / 1000);
    }

    _checkCollisionAndCleanup();
    setState(() {});
  }

  void _checkCollisionAndCleanup() {
    if (lastSize == null) return;

    final width = lastSize!.width;
    final height = lastSize!.height;

    final basketW = width * basketWidthRatio * 0.9;
    final basketH = height * basketHeightRatio * 0.9;
    final basketLeft = (basketX * width) - basketW / 2;
    final basketTop = height * 0.78;
    final basketRect = Rect.fromLTWH(
      basketLeft,
      basketTop + basketH * 0.2,
      basketW,
      basketH,
    );

    final toRemove = <DropItem>[];

    for (final it in items) {
      final itemW = width * it.size * 0.9;
      final itemH = itemW;
      final itemLeft = (it.x * width) - itemW / 2;
      final itemTop = (it.y * height);
      final itemRect = Rect.fromLTWH(
        itemLeft,
        itemTop + itemH * 0.1,
        itemW,
        itemH,
      );

      if (itemTop > height * 0.92) {
        toRemove.add(it);
        continue;
      }

      if (basketRect.overlaps(itemRect)) {
        if (it.type == DropType.dumbbell) {
          score += 1;
          toRemove.add(it);
        } else {
          _endGame();
          return;
        }
      }
    }

    items.removeWhere(toRemove.contains);
  }

  void _moveLeft() {
    if (over) return;
    basketX -= 0.08;
    if (basketX < 0.08) basketX = 0.08;
    setState(() {});
  }

  void _moveRight() {
    if (over) return;
    basketX += 0.08;
    if (basketX > 0.92) basketX = 0.92;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bc) {
        lastSize = Size(bc.maxWidth, bc.maxHeight);
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const _TopBar(),
                  const SizedBox(height: 8),

                  // 배경만 표시 (시간 제거)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 3),
                        borderRadius: BorderRadius.zero,
                        image: const DecorationImage(
                          image: AssetImage('assets/gym.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        ...items.map((it) => _FallingSprite(item: it)),

                        Align(
                          alignment: Alignment((basketX - 0.5) * 2, 0.8),
                          child: _Basket(
                            widthRatio: basketWidthRatio,
                            heightRatio: basketHeightRatio,
                          ),
                        ),

                        Align(
                          alignment: const Alignment(0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _MovButton(
                                  icon: Icons.arrow_back,
                                  onPressed: _moveLeft,
                                ),
                                _MovButton(
                                  icon: Icons.arrow_forward,
                                  onPressed: _moveRight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 좌/우 이동 버튼
class _MovButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _MovButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white10,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}

/// 떨어지는 아이템 스프라이트
class _FallingSprite extends StatelessWidget {
  final DropItem item;
  const _FallingSprite({required this.item});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(item.x * 2 - 1, item.y * 2 - 1),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * item.size,
        height: MediaQuery.of(context).size.width * item.size,
        child: _spriteFor(item.type),
      ),
    );
  }

  Widget _spriteFor(DropType t) {
    switch (t) {
      case DropType.dumbbell:
        return _tryAsset(
          'assets/images/insideMiniGame/dumbbell.png',
          fallback: const Text(
            '🏋️',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28),
          ),
        );
      case DropType.beer:
        return _tryAsset(
          'assets/images/insideMiniGame/beer.png',
          fallback: const Text(
            '🍺',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28),
          ),
        );
      case DropType.cola:
        return _tryAsset(
          'assets/images/insideMiniGame/cola.png',
          fallback: const Text(
            '🥤',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28),
          ),
        );
      case DropType.chicken:
        return _tryAsset(
          'assets/images/insideMiniGame/chicken.png',
          fallback: const Text(
            '🍗',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28),
          ),
        );
    }
  }

  Widget _tryAsset(String path, {required Widget fallback}) {
    return Image.asset(
      path,
      errorBuilder: (_, __, ___) => Center(child: fallback),
      filterQuality: FilterQuality.none,
      fit: BoxFit.contain,
    );
  }
}

/// 바구니
class _Basket extends StatelessWidget {
  final double widthRatio;
  final double heightRatio;
  const _Basket({required this.widthRatio, required this.heightRatio});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * widthRatio;
    final h = MediaQuery.of(context).size.height * heightRatio;
    return SizedBox(
      width: w,
      height: h,
      child: CustomPaint(painter: _BasketPainter()),
    );
  }
}

class _BasketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = const Color(0xFFB0852B);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF7A5A1A);

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(0),
    );
    canvas.drawRRect(r, base);
    canvas.drawRRect(r, edge);

    final inner = Rect.fromLTWH(
      size.width * .08,
      size.height * .25,
      size.width * .84,
      size.height * .50,
    );
    canvas.drawRect(inner, edge);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ─────────────────────────────────────────────────
/// 페이지 3: 결과
class GymResultPage extends StatelessWidget {
  final int score;
  const GymResultPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final coins = score * 10;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _TopBar(),
              const SizedBox(height: 8),

              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/gym.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const Spacer(),
              Text(
                '🎉  $score개 성공  🎉',
                style: const TextStyle(fontFamily: 'Galmuri11', fontSize: 34),
              ),
              const SizedBox(height: 12),
              Text(
                '$coins 코인이 적립됩니다',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const GymIntroPage()),
                      (r) => false,
                    );
                  },
                  child: const Text(
                    '처음으로',
                    style: TextStyle(fontFamily: 'Galmuri11', fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
