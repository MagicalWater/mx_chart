import 'dart:ui';

/// 買賣圖表的顏色設定檔
class VolumeChartColorSetting {
  /// 背景顏色
  final Color background;

  /// 左上角的指標數值說明文字顏色
  final Color indexTip;

  /// 長柱在漲時的顏色
  final Color barUp;

  /// 長柱在跌時的顏色
  final Color barDown;

  /// 右側最大值數值
  /// 圖表右側的數值說明顏色
  final Color rightMaxValueText;

  const VolumeChartColorSetting({
    this.background = const Color(0xff1e2129),
    this.indexTip = const Color(0xff4729AE),
    this.barUp = const Color(0xff1d5f5e),
    this.barDown = const Color(0xff82363a),
    this.rightMaxValueText = const Color(0xff60738E),
  });
}
