// lib/pages/Inside/inside_explore_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/Inside/RoomSelectController.dart';
import 'package:frontend/pages/Inside/SpaceList/space_catalog.dart';
import 'package:frontend/pages/MainPage/api/building/building_model.dart';

class InsideExplorePage extends StatefulWidget {
  final BuildingType buildingType;
  final int floors;                 // 총 층수
  final int startFloor;             // 시작 층 (1..floors)
  final int startCol;               // 시작 칸 (1 또는 2)
  /// 잠금이 풀린 최대 층(포함). 기본값=전체 층(=모두 열림)
  final int maxUnlockedFloor;

  const InsideExplorePage({
    super.key,
    required this.buildingType,
    required this.floors,
    this.startFloor = 1,
    this.startCol = 1,
    int? maxUnlockedFloor,
  }) : maxUnlockedFloor = maxUnlockedFloor ?? floors;

  @override
  State<InsideExplorePage> createState() => _InsideExplorePageState();
}

class _InsideExplorePageState extends State<InsideExplorePage> {
  late final RoomSelectionController ctrl;
  late int curFloor; // 1..floors
  late int curCol;   // 1(left) or 2(right)

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<RoomSelectionController>();
    curFloor = widget.startFloor.clamp(1, widget.floors);
    curCol   = widget.startCol.clamp(1, 2);
  }

  // 현재(층,칸) → 슬롯번호
  int _slotNumberOf(int floor, int col) => (floor - 1) * 2 + col;

  // 미리보기용: 해당 층의 좌/우 칸 이미지 2장을 가로로 배치
  Widget _floorPreviewRow(int floor, {bool dim = false, bool showLock = false}) {
    final leftPath  = ctrl.stagedBoxImages[_slotNumberOf(floor, 1)] ?? 'images/inside/empty.png';
    final rightPath = ctrl.stagedBoxImages[_slotNumberOf(floor, 2)] ?? 'images/inside/empty.png';

    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Image.asset(leftPath, fit: BoxFit.cover, filterQuality: FilterQuality.none),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Image.asset(rightPath, fit: BoxFit.cover, filterQuality: FilterQuality.none),
            ),
          ],
        ),
        if (dim || showLock)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(showLock ? 0.45 : 0.25),
              child: showLock
                  ? const Center(
                      child: Icon(Icons.lock, color: Colors.white, size: 28),
                    )
                  : null,
            ),
          ),
      ],
    );
  }

  // 1층 아래 미리보기: 문(좌/우) 표시
  Widget _doorPreviewRow() {
    return Row(
      children: [
        Expanded(
          child: Image.asset('images/inside/door_left.png',
              fit: BoxFit.cover, filterQuality: FilterQuality.none),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Image.asset('images/inside/door_right.png',
              fit: BoxFit.cover, filterQuality: FilterQuality.none),
        ),
      ],
    );
  }

  // 이동 제약 및 이동
  bool get _canUp    => curFloor < widget.floors && curFloor < widget.maxUnlockedFloor;
  bool get _canDown  => curFloor > 1;
  bool get _canLeft  => curCol > 1;
  bool get _canRight => curCol < 2;

  Future<void> _alert(String msg) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _moveUp() async {
    if (curFloor >= widget.floors) {
      await _alert('마지막 층입니다.');
      return;
    }
    if (curFloor >= widget.maxUnlockedFloor) {
      await _alert('아직 잠겨 있어요. 현재 층의 슬롯을 모두 설치하면 다음 층이 열립니다.');
      return;
    }
    setState(() => curFloor += 1);
  }

  Future<void> _moveDown() async {
    if (curFloor <= 1) {
      await _alert('1층입니다.');
      return;
    }
    setState(() => curFloor -= 1);
  }

  void _moveLeft()  { if (_canLeft)  setState(() => curCol = 1); }
  void _moveRight() { if (_canRight) setState(() => curCol = 2); }

  @override
  Widget build(BuildContext context) {
    final currentImg = ctrl.stagedBoxImages[_slotNumberOf(curFloor, curCol)] ?? 'images/inside/empty.png';
    final topHas = curFloor < widget.floors;
    final bottomHas = curFloor > 1;

    // 위/아래 미리보기 높이
    const double previewH = 90; // 기기별로 살짝 보이는 정도

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 상단 바
            Positioned(
              left: 12, right: 12, top: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: const Text('나가기',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),

            // 메인 콘텐츠
            Positioned.fill(
              top: 40,
              child: Column(
                children: [
                  // 위층 미리보기(있다면)
                  if (topHas)
                    SizedBox(
                      height: previewH,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _floorPreviewRow(
                            curFloor + 1,
                            // 미리보기는 살짝 어둡게
                            dim: true,
                            // 위층이 잠금이면 자물쇠
                            showLock: (curFloor >= widget.maxUnlockedFloor),
                          ),
                        ),
                      ),
                    ),

                  // 현재 층 타이틀
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${curFloor}F',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // 현재 칸 크게 보기
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 2, // 각 칸이 2:1 비율로 보여지도록
                        child: ClipRect(
                          child: Image.asset(
                            currentImg,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 아래층 미리보기(있다면) - 1층 아래는 "문" 이미지
                  SizedBox(
                    height: previewH,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: curFloor == 1
                            ? _doorPreviewRow()
                            : bottomHas
                                ? _floorPreviewRow(curFloor - 1, dim: true)
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 네 방향 버튼
            Positioned(
              right: 18,
              bottom: 24,
              child: _ArrowPad(
                onUp: _moveUp,
                onDown: _moveDown,
                onLeft: _moveLeft,
                onRight: _moveRight,
                canUp: _canUp,
                canDown: _canDown,
                canLeft: _canLeft,
                canRight: _canRight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowPad extends StatelessWidget {
  final VoidCallback onUp, onDown, onLeft, onRight;
  final bool canUp, canDown, canLeft, canRight;

  const _ArrowPad({
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
    required this.canUp,
    required this.canDown,
    required this.canLeft,
    required this.canRight,
  });

  Widget _btn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFF2E2E2E) : const Color(0xFF424242),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _btn(Icons.keyboard_arrow_up, canUp ? onUp : null),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _btn(Icons.keyboard_arrow_left,  canLeft  ? onLeft  : null),
            _btn(Icons.keyboard_arrow_down,  canDown  ? onDown  : null),
            _btn(Icons.keyboard_arrow_right, canRight ? onRight : null),
          ],
        ),
      ],
    );
  }
}
