import 'kdj_chart_color_setting.dart';
import 'kdj_chart_size_setting.dart';

export 'kdj_chart_color_setting.dart';
export 'kdj_chart_size_setting.dart';

class KDJChartUiStyle {
  /// 顏色設定
  final KDJChartColorSetting colorSetting;

  /// 尺寸相關設定
  final KDJChartSizeSetting sizeSetting;

  /// 是否顯示grid
  final bool gridEnabled;

  const KDJChartUiStyle({
    this.colorSetting = const KDJChartColorSetting(),
    this.sizeSetting = const KDJChartSizeSetting(),
    this.gridEnabled = true,
  });
}
