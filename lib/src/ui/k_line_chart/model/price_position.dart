/// 價格標示y軸位置獲取
/// [rightSpace] - 最新價格距離最右側的距離
/// [isNewerDisplay] - 最新的一筆資料是否顯示中
/// [priceToY] - 傳入price, 轉化成對應的y軸
typedef ChartPositionGetter = void Function(
  double rightSpace,
  bool isNewerDisplay,
  double Function(double price) priceToY,
  double Function(double price) priceToYWithClamp,
);

/// 價格的位置
class PricePosition {
  /// 畫布最大的寬度
  final double canvasWidth;

  /// 最新一筆的價格
  final double? lastPrice;

  /// 最新的一筆資料是否顯示中
  final bool isNewerDisplay;

  /// 對應[ChartPositionGetter]的[rightSpace]
  final double rightSpace;

  /// 對應[ChartPositionGetter.priceToY]
  final double Function(double price) priceToY;

  /// 對應[ChartPositionGetter.priceToYWithClamp]
  final double Function(double price) priceToYWithClamp;

  PricePosition({
    required this.canvasWidth,
    required this.rightSpace,
    required this.priceToY,
    required this.priceToYWithClamp,
    required this.lastPrice,
    required this.isNewerDisplay,
  });
}
