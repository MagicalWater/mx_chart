import 'dart:ui';

/// 買賣圖表的顏色設定檔
class MACDChartColorSetting {
  /// 背景顏色
  final Color background;

  /// DIF(快線)/DEA(慢線)
  final Color difColor;
  final Color deaColor;

  /// MACD指標文字顏色
  final Color macdTip;

  /// MACD統計顏色
  final Color statisticsTip;

  /// 柱子在正時上漲顏色
  final Color positiveUpColor;

  /// 柱子在正時下跌顏色
  final Color positiveDownColor;

  /// 柱子在負時下跌顏色
  final Color negativeDownColor;

  /// 柱子在負時上漲顏色
  final Color negativeUpColor;

  /// 右側數值顏色
  final Color rightValueText;

  const MACDChartColorSetting({
    this.background = const Color(0xff1e2129),
    this.difColor = const Color(0xffae33ba),
    this.deaColor = const Color(0xff59d0d0),
    this.macdTip = const Color(0xffb8d651),
    this.statisticsTip = const Color(0xff60738E),
    this.positiveUpColor = const Color(0xff1d5f5e),
    this.positiveDownColor = const Color(0xff3b9594),
    this.negativeDownColor = const Color(0xffc6676c),
    this.negativeUpColor = const Color(0xff82363a),
    this.rightValueText = const Color(0xff60738E),
  });
}
