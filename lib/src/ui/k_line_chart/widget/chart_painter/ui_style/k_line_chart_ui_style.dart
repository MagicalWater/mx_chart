import '../chart_painter.dart';

export 'chart_color_setting.dart';
export 'chart_height_ratio_setting.dart';
export 'chart_size_setting.dart';

class KLineChartUiStyle {
  final ChartSizeSetting sizeSetting;
  final ChartHeightRatioSetting heightRatioSetting;
  final ChartColorSetting colorSetting;

  const KLineChartUiStyle({
    this.sizeSetting = const ChartSizeSetting(),
    this.colorSetting = const ChartColorSetting(),
    this.heightRatioSetting = const ChartHeightRatioSetting(
      mainRatio: 0.7,
      volumeRatio: 0.15,
      indicatorRatio: 0.15,
    ),
  });

  KLineChartUiStyle copyWith({
    ChartHeightRatioSetting? heightRatioSetting,
  }) {
    return KLineChartUiStyle(
      sizeSetting: sizeSetting,
      heightRatioSetting: heightRatioSetting ?? this.heightRatioSetting,
      colorSetting: colorSetting,
    );
  }
}
