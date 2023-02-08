part of '../view/k_line_chart.dart';

class KLineChartController {
  _KLineChartState? _bind;

  /// 滾動回起點
  /// [animated] - 是否使用動畫滾動
  Future<void> scroll1ToRight({bool animated = true}) async {
    if (_bind == null) {
      if (kDebugMode) {
        print('錯誤: KLineChartController尚未綁定至KLineChart上, 忽略此次請求');
      }
    }
    return _bind?.scrollToRight(animated: animated);
  }

  void dispose() {
    _bind = null;
  }
}
