import 'rsi_chart_color_setting.dart';
import 'rsi_chart_size_setting.dart';

export 'rsi_chart_color_setting.dart';
export 'rsi_chart_size_setting.dart';

class RSIChartUiStyle {
  /// 顏色設定
  final RSIChartColorSetting colorSetting;

  /// 尺寸相關設定
  final RSIChartSizeSetting sizeSetting;

  const RSIChartUiStyle({
    this.colorSetting = const RSIChartColorSetting(),
    this.sizeSetting = const RSIChartSizeSetting(),
  });
}
