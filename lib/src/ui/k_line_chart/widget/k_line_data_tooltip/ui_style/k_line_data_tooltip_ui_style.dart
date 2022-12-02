import 'k_line_data_tooltip_color_setting.dart';
import 'k_line_data_tooltip_size_setting.dart';

export 'k_line_data_tooltip_color_setting.dart';
export 'k_line_data_tooltip_size_setting.dart';

class KLineDataTooltipUiStyle {
  final KLineDataTooltipSizeSetting sizeSetting;
  final KLineDataTooltipColorSetting colorSetting;

  const KLineDataTooltipUiStyle({
    this.sizeSetting = const KLineDataTooltipSizeSetting(),
    this.colorSetting = const KLineDataTooltipColorSetting(),
  });
}
