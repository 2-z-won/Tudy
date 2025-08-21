import 'package:get/get.dart';

class MoneyController extends GetxController {
  RxInt money = 1000.obs;

  void addMoney(int amount) {
    money.value += amount;
  }

  void subtractMoney(int amount) {
    money.value -= amount;
  }
}
