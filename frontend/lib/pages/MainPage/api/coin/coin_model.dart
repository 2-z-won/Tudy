// lib/pages/MainPage/api/coin/coin_model.dart
class Coin {
  final String coinType;
  final int amount;

  const Coin({
    required this.coinType,
    required this.amount,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      coinType: json['coinType'] as String,
      amount: (json['amount'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'coinType': coinType,
        'amount': amount,
      };
}
