import 'rsi_chart_color_setting.dart';
import 'rsi_chart_size_setting.dart';

export 'rsi_chart_color_setting.dart';
export 'rsi_chart_size_setting.dart';

class RSIChartUiStyle {
  /// 顏色設定
  final RSIChartColorSetting colorSetting;

  /// 尺寸相關設定
  final RSIChartSizeSetting sizeSetting;

  /// 是否顯示grid
  final bool gridEnabled;

  const RSIChartUiStyle({
    this.colorSetting = const RSIChartColorSetting(),
    this.sizeSetting = const RSIChartSizeSetting(),
    this.gridEnabled = true,
  });

  RSIChartUiStyle copyWith({
    RSIChartColorSetting? colorSetting,
    RSIChartSizeSetting? sizeSetting,
    bool? gridEnabled,
  }) {
    return RSIChartUiStyle(
      colorSetting: colorSetting ?? this.colorSetting,
      sizeSetting: sizeSetting ?? this.sizeSetting,
      gridEnabled: gridEnabled ?? this.gridEnabled,
    );
  }
}
