import 'macd_chart_color_setting.dart';
import 'macd_chart_size_setting.dart';

export 'macd_chart_color_setting.dart';
export 'macd_chart_size_setting.dart';

class MACDChartUiStyle {
  /// 顏色設定
  final MACDChartColorSetting colorSetting;

  /// 尺寸相關設定
  final MACDChartSizeSetting sizeSetting;

  /// 是否顯示grid
  final bool gridEnabled;

  const MACDChartUiStyle({
    this.colorSetting = const MACDChartColorSetting(),
    this.sizeSetting = const MACDChartSizeSetting(),
    this.gridEnabled = true,
  });
}
