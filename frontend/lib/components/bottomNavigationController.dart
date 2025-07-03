import 'package:get/get.dart';

class MyBottomNavigationController extends GetxController {
  static MyBottomNavigationController get to => Get.find();

  final RxInt selectedIndex = 1.obs;

  final RxInt shadowIndex = (-1).obs;

  void changeIndex(int index) {
    selectedIndex(index);

    shadowIndex(index); // 그림자 효과 ON

    Future.delayed(const Duration(milliseconds: 200), () {
      if (shadowIndex.value == index) {
        shadowIndex(-1); // 그림자 OFF
      }
    });

    switch (index) {
      case 0:
        Get.toNamed('/main');
        break;
      case 1:
        Get.toNamed('/main');
        break;
      case 2:
        Get.toNamed('/main');
        break;
    }
  }
}
