import 'wr_chart_color_setting.dart';
import 'wr_chart_size_setting.dart';

export 'wr_chart_color_setting.dart';
export 'wr_chart_size_setting.dart';

class WRChartUiStyle {
  /// 顏色設定
  final WRChartColorSetting colorSetting;

  /// 尺寸相關設定
  final WRChartSizeSetting sizeSetting;

  const WRChartUiStyle({
    this.colorSetting = const WRChartColorSetting(),
    this.sizeSetting = const WRChartSizeSetting(),
  });
}
