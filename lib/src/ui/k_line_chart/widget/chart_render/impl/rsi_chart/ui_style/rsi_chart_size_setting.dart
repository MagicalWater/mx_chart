/// 主圖表的尺寸相關設定
class RSIChartSizeSetting {
  /// 左上角的各指標提示
  final double indexTip;

  /// 指標線(rsi)寬度
  final double lineWidth;

  /// 右側數值
  /// 圖表右側的數值說明
  final double rightValueText;

  /// 圖表上方/下方padding
  final double topPadding;
  final double bottomPadding;

  const RSIChartSizeSetting({
    this.indexTip = 11,
    this.lineWidth = 1.3,
    this.rightValueText = 12,
    this.topPadding = 18,
    this.bottomPadding = 4,
  });
}
