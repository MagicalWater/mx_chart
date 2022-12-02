import 'dart:ui';

/// 主圖表的尺寸相關設定
class VolumeChartSizeSetting {
  /// 左上角的各指標提示
  final double indexTip;

  /// volume的長條圖柱子寬度
  final double barWidth;

  /// 右側最大值數值
  /// 圖表右側的數值說明
  final double rightMaxValueText;

  /// 圖表上方/下方padding
  final double topPadding;
  final double bottomPadding;

  const VolumeChartSizeSetting({
    this.indexTip = 11,
    this.barWidth = 7,
    this.rightMaxValueText = 12,
    this.topPadding = 15,
    this.bottomPadding = 4,
  });
}
