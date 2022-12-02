/// tooltip尺寸相關設定
class KLineDataTooltipSizeSetting {
  /// 前綴文字大小
  final double prefixText;

  /// 數值文字
  final double valueText;

  /// border寬度
  final double borderWidth;

  /// 內容padding
  final double horizontalPadding;
  final double verticalPadding;

  /// 外框margin
  final double horizontalMargin;
  final double topMargin;

  const KLineDataTooltipSizeSetting({
    this.prefixText = 10,
    this.valueText = 10,
    this.horizontalPadding = 8,
    this.verticalPadding = 7,
    this.horizontalMargin = 10,
    this.topMargin = 25,
    this.borderWidth = 0.5,
  });
}
