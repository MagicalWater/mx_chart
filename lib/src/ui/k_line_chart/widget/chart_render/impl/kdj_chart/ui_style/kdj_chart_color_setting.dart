import 'dart:ui';

/// 買賣圖表的顏色設定檔
class KDJChartColorSetting {
  /// 背景顏色
  final Color background;

  /// k/d/j
  final Color kColor;
  final Color dColor;
  final Color jColor;

  /// KDJ指標文字顏色
  final Color kdjTip;

  /// 右側數值顏色
  final Color rightValueText;

  /// 頂部分隔線
  final Color topDivider;

  /// 底部分隔線
  final Color bottomDivider;

  const KDJChartColorSetting({
    this.background = const Color(0xff1e2129),
    this.kColor = const Color(0xffb47731),
    this.dColor = const Color(0xffae33ba),
    this.jColor = const Color(0xff59d0d0),
    this.kdjTip = const Color(0xff60738E),
    this.rightValueText = const Color(0xff60738E),
    this.topDivider = const Color(0xff4C86CD),
    this.bottomDivider = const Color(0xff4C86CD),
  });
}
