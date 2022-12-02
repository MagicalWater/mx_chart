import 'volume_chart_color_setting.dart';
import 'volume_chart_size_setting.dart';

export 'volume_chart_color_setting.dart';
export 'volume_chart_size_setting.dart';

class VolumeChartUiStyle {
  /// 顏色設定
  final VolumeChartColorSetting colorSetting;

  /// 尺寸相關設定
  final VolumeChartSizeSetting sizeSetting;

  const VolumeChartUiStyle({
    this.colorSetting = const VolumeChartColorSetting(),
    this.sizeSetting = const VolumeChartSizeSetting(),
  });
}
