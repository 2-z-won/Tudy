// lib/pages/MainPage/api/coin/coin_model.dart
class Coin {
  final String coinType; // ACADEMIC_SAEDO | CAFE | GYM
  final int amount; // balance

  const Coin({required this.coinType, required this.amount});

  // 응답 바디엔 coinType이 없으므로, 호출자가 coinType을 같이 넘겨줌
  factory Coin.fromJson(String coinType, Map<String, dynamic> json) {
    return Coin(coinType: coinType, amount: (json['balance'] as num).toInt());
  }

  Map<String, dynamic> toJson() => {'coinType': coinType, 'balance': amount};
}
