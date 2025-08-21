import 'package:flutter/material.dart';
import 'package:frontend/pages/MainPage/api/coin/coin_controller.dart';
import 'package:get/get.dart';

/// 컨트롤러만 주면 선택/목록/이미지/금액 표시는 모두 내부에서 처리
class CoinDropdownSimple extends StatefulWidget {
  final CoinsController ctrl;
  final bool showTypeLabel; // 선택행에 타입 텍스트도 보일지(옵션)
  const CoinDropdownSimple({
    super.key,
    required this.ctrl,
    this.showTypeLabel = false,
  });

  @override
  State<CoinDropdownSimple> createState() => _CoinDropdownSimpleState();
}

class _CoinDropdownSimpleState extends State<CoinDropdownSimple>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ac;
  late final Animation<double> _size;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _size = CurvedAnimation(parent: _ac, curve: Curves.easeInOut);
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeIn);
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      _open ? _ac.forward() : _ac.reverse();
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const txt = TextStyle(color: Colors.black);

    Widget coinRow({
      required String img,
      required String amount,
      String? typeLabel,
    }) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            img,
            width: 20,
            height: 20,
            filterQuality: FilterQuality.none,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 20,
              height: 20,
              child: Icon(Icons.monetization_on, size: 18),
            ),
          ),
          const SizedBox(width: 6),
          if (typeLabel != null) ...[
            Text(typeLabel, style: txt),
            const SizedBox(width: 6),
          ],
          Text(amount, style: txt),
        ],
      );
    }

    final ctrl = widget.ctrl;

    return Obx(() {
      // 로딩/에러/빈 상태 처리
      if (ctrl.error.isNotEmpty) {
        return Text(
          ctrl.error.value,
          style: const TextStyle(color: Colors.red),
        );
      }
      if (ctrl.isLoading.value && ctrl.coins.isEmpty) {
        // 로딩 중일 때: 그냥 아이콘 + 0 보여주기
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/coin/ACADEMIC_SAEDO.png', // 기본 코인 아이콘 (새도)
              width: 20,
              height: 20,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.monetization_on, size: 18),
            ),
            const SizedBox(width: 6),
            const Text("0", style: TextStyle(color: Colors.black)),
          ],
        );
      }

      if (ctrl.coins.isEmpty) {
        return const Text(
          '코인 정보가 없습니다',
          style: TextStyle(color: Colors.black54),
        );
      }

      // 선택된 타입 결정 (없으면 리스트 첫 번째로 대체)
      final selectedType = (ctrl.selectedType.value.isNotEmpty)
          ? ctrl.selectedType.value
          : (ctrl.coins.any((c) => c.coinType == 'ACADEMIC_SAEDO')
                ? 'ACADEMIC_SAEDO'
                : ctrl.coins.first.coinType);

      final selectedAmount = ctrl.amountTextOf(selectedType);
      final selectedImg = ctrl.imagePathOf(selectedType);

      // 펼침 목록(선택 제외)
      final menuTypes = ctrl.coins
          .map((c) => c.coinType)
          .where((t) => t != selectedType)
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 선택된 항목
          GestureDetector(
            onTap: _toggle,
            child: coinRow(
              img: selectedImg,
              amount: selectedAmount,
              typeLabel: widget.showTypeLabel ? selectedType : null,
            ),
          ),

          // 펼침 목록
          SizeTransition(
            sizeFactor: _size,
            axisAlignment: 1.0,
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: menuTypes.map((type) {
                  return GestureDetector(
                    onTap: () {
                      ctrl.select(type); // 선택만 바꾸면 Obx가 갱신
                      // 필요 시 최신화: ctrl.fetchOne(type);
                      _toggle();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: coinRow(
                        img: ctrl.imagePathOf(type),
                        amount: ctrl.amountTextOf(type),
                        typeLabel: widget.showTypeLabel ? type : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}
