///  繪製完成後獲取到的訊息
class DrawContentInfo {
  /// x軸可滑動最大距離
  final double maxScrollX;

  /// 圖表總寬度
  final double chartTotalWidth;

  /// 畫布寬度
  final double canvasWidth;

  DrawContentInfo({
    required this.maxScrollX,
    required this.chartTotalWidth,
    required this.canvasWidth,
  });
}
