import 'package:frontend/pages/Inside/SpaceList/space_catalog.dart';

String spaceImg(BuildingType b, String type, int level, {int maxLevel = 5}) {
  final l = level.clamp(1, maxLevel);
  // 카드/내부 동일 경로
  return 'images/inside/${b.name}_CARD/${type}_$l.png';
}
