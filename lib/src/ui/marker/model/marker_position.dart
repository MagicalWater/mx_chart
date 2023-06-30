/// 標記位置
class MarkerPosition {
  /// x軸位置
  final DateTime dateTime;

  /// x軸的精細位置
  final double xRate;

  /// y軸位置
  final double price;

  const MarkerPosition({
    required this.dateTime,
    required this.xRate,
    required this.price,
  });

  /// 將資料轉為 Map
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toString(),
      'xRate': xRate,
      'price': price,
    };
  }

  /// 將 Map 轉為資料
  factory MarkerPosition.fromMap(Map<String, dynamic> map) {
    return MarkerPosition(
      dateTime: DateTime.parse(map['dateTime'] as String),
      xRate: map['xRate'],
      price: map['price'],
    );
  }
}
