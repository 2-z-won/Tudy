import 'package:get/get.dart';

class RoomSelectionController extends GetxController {
  var selectedCard = RxnString(); // nullable String observable

  var boxValues = <int, RxnString>{}; // index별로 카드 이름 저장

  RoomSelectionController() {
    for (int i = 1; i <= 10; i++) {
      boxValues[i] = RxnString(); // 초기화
    }
  }

  void selectCard(String? name) {
    selectedCard.value = name;
  }

  void assignToBox(int index) {
    print('selectedCard: ${selectedCard.value}');
    if (selectedCard.value != null) {
      boxValues[index]?.value = selectedCard.value;
    }
  }
}
