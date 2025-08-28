import 'package:flutter/material.dart';

// 게임 페이지들
import '../pages/real_coinflip.dart';
import '../pages/updown_game.dart';
import '../pages/oddeven_game.dart';

class GameDialog extends StatelessWidget {
  const GameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_GameItem>[
      _GameItem(
        iconPath: 'images/game_buttons/button1.png',
        title: '', // 제목 숨김
        page: const OddEvenGamePage(),
      ),
      _GameItem(
        iconPath: 'images/game_buttons/button2.png',
        title: '', // 제목 숨김
        page: const UpDownGamePage(),
      ),
      _GameItem(
        iconPath: 'images/game_buttons/button3.png',
        title: '', // 제목 숨김
        page: const CoinTossGamePage(),
      ),
    ];

    return Dialog(
      backgroundColor: const Color(0x00000000),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          constraints: const BoxConstraints(maxWidth: 460),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F23),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x89000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더(제목 정확히 가운데 정렬)
              Row(
                children: [
                  const SizedBox(width: 40), // 좌측 균형 공간
                  const Expanded(
                    child: Text(
                      '미니게임',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      // 필요 시: Navigator.of(context, rootNavigator: true).pop();
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 카드 3개 (간격으로 구분)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: items
                    .map(
                      (e) => _GameTile(
                        item: e,
                        onTap: () {
                          // 선택 다이얼로그 닫고 -> 게임 다이얼로그 열기
                          Navigator.pop(context);
                          Future.microtask(() {
                            _openGameAsDialog(
                              context,
                              title: e.title, // 현재 내부에선 미사용
                              page: e.page,
                            );
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 게임을 **모달 다이얼로그**로 실행
void _openGameAsDialog(
  BuildContext context, {
  required String title, // 시그니처 유지만, 내부에서는 미사용
  required Widget page,
}) {
  final size = MediaQuery.of(context).size;

  // 정확한 폭/높이 고정 (toDouble로 안전 캐스팅)
  final double dialogWidth = (size.width - 32).clamp(320.0, 440.0).toDouble();
  final double dialogHeight = (size.height * 0.68)
      .clamp(480.0, 600.0)
      .toDouble();

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (dialogCtx) => WillPopScope(
      // 안드로이드 Back → 그냥 닫기(메인으로)
      onWillPop: () async => true,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.white,
              // ✅ 외부 헤더 없이 게임 페이지만 넣음
              child: page,
            ),
          ),
        ),
      ),
    ),
  );
}

/* ---------------- 내부 위젯 ---------------- */

class _GameItem {
  final String iconPath;
  final String title;
  final Widget page;
  const _GameItem({
    required this.iconPath,
    required this.title,
    required this.page,
  });
}

class _GameTile extends StatefulWidget {
  const _GameTile({required this.item, required this.onTap});
  final _GameItem item;
  final VoidCallback onTap;

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hasTitle = widget.item.title.trim().isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 128,
        height: hasTitle ? 136 : 112, // 제목 없으면 더 컴팩트
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF2A2E31) : const Color(0xFF2E3338),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3F45), width: 1),
          boxShadow: _pressed
              ? const []
              : const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF33383D), Color(0xFF282C30)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              widget.item.iconPath,
              width: 54,
              height: 54,
              filterQuality: FilterQuality.none, // 픽셀 또렷
              isAntiAlias: false,
            ),
            if (hasTitle) ...[
              const SizedBox(height: 10),
              Text(
                widget.item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
