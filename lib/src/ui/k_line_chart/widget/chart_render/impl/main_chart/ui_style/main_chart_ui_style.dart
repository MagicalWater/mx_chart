import 'main_chart_color_setting.dart';
import 'main_chart_size_setting.dart';

export 'main_chart_color_setting.dart';
export 'main_chart_size_setting.dart';

class MainChartUiStyle {
  /// 顏色設定
  final MainChartColorSetting colorSetting;

  /// 尺寸相關設定
  final MainChartSizeSetting sizeSetting;

  const  MainChartUiStyle({
    this.colorSetting = const MainChartColorSetting(),
    this.sizeSetting = const MainChartSizeSetting(),
  });
}
