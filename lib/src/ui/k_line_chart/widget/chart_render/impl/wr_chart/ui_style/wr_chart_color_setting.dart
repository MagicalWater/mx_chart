import 'dart:ui';

/// 買賣圖表的顏色設定檔
class WRChartColorSetting {
  /// 背景顏色
  final Color background;

  /// wr各週期顏色, 將會依照週期排序
  final List<Color> wrLine;

  /// 右側數值顏色
  final Color rightValueText;

  const WRChartColorSetting({
    this.background = const Color(0xff1e2129),
    this.wrLine = const [
      Color(0xffb47731),
      Color(0xffae33ba),
      Color(0xff59d0d0),
    ],
    this.rightValueText = const Color(0xff60738E),
  });
}
