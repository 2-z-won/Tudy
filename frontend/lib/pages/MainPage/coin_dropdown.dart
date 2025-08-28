import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/MainPage/api/coin/coin_controller.dart';

class CoinDropdownSimple extends StatefulWidget {
  final CoinsController ctrl;
  final bool showTypeLabel;
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
      duration: const Duration(milliseconds: 180),
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
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.monetization_on, size: 18),
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
      // 선택 타입: 있으면 그걸 쓰고, 없으면 ACADEMIC_SAEDO 우선, 그것도 없으면 첫 코인 타입
      final selectedType = (ctrl.selectedType.value.isNotEmpty)
          ? ctrl.selectedType.value
          : (ctrl.coins.any((c) => c.coinType == 'ACADEMIC_SAEDO')
                ? 'ACADEMIC_SAEDO'
                : (ctrl.coins.isNotEmpty
                      ? ctrl.coins.first.coinType
                      : 'ACADEMIC_SAEDO'));

      // ★ 요구사항: 데이터 오기 전엔 0, 오면 바로 교체
      final selectedAmount = ctrl.amountTextOf(selectedType); // 없으면 "0" 리턴
      final selectedImg = ctrl.imagePathOf(selectedType);

      // 펼침 목록(선택 제외). coins가 비어도 그냥 빈 목록 → 메뉴는 안 뜸
      final menuTypes = ctrl.coins
          .map((c) => c.coinType)
          .where((t) => t != selectedType)
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 선택된 항목 (탭하면 토글)
          GestureDetector(
            onTap: () {
              if (menuTypes.isEmpty) return; // 항목 없으면 펼치지 않음
              _toggle();
            },
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
                      ctrl.select(type); // 선택 변경만 → 상단 즉시 갱신
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
