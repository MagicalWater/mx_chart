import 'dart:math';

import '../ui/k_line_chart/model/model.dart';

/// 圖表技術指標計算
class WrCalculator {
  static void calculateWrAtLast({
    List<int> periods = const [6, 13],
    required List<KLineData> oriData,
    required List<KLineData> newData,
  }) {
    final datas = [...oriData, ...newData];
    final startIndex = oriData.length;

    for (var i = startIndex; i < datas.length; i++) {
      final data = datas[i];
      final indicator = data.indicatorData.wr ?? IndicatorWR();

      for (var j = 0; j < periods.length; j++) {
        final period = periods[j];
        int startIndex = i - period;
        if (startIndex < 0) {
          startIndex = 0;
        }
        var maxPrice = -double.maxFinite;
        var minPrice = double.maxFinite;
        for (var index = startIndex; index <= i; index++) {
          maxPrice = max(maxPrice, datas[index].high);
          minPrice = min(minPrice, datas[index].low);
        }

        if (i >= period) {
          final double wr;
          if ((maxPrice - minPrice) == 0) {
            wr = 0;
          } else {
            wr = 100 * (maxPrice - datas[i].close) / (maxPrice - minPrice);
          }
          indicator.wr[period] = wr;
          data.indicatorData.wr = indicator;
        }
      }
    }
  }

  /// 計算威廉指標(兼具超買超賣和強弱分界的指標)
  /// 計算說明
  /// WR = (週期內最高價 – 收盤價) / (週期內最高價 – 週期內最低價) * 100
  ///
  /// [periods] - 週期, 默認為[6, 13]
  static void calculateWR({
    List<int> periods = const [6, 13],
    required List<KLineData> datas,
    bool coverExist = true,
  }) {
    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      final indicator = data.indicatorData.wr ?? IndicatorWR();

      for (var j = 0; j < periods.length; j++) {
        final period = periods[j];
        int startIndex = i - period;
        if (startIndex < 0) {
          startIndex = 0;
        }
        var maxPrice = -double.maxFinite;
        var minPrice = double.maxFinite;
        for (var index = startIndex; index <= i; index++) {
          maxPrice = max(maxPrice, datas[index].high);
          minPrice = min(minPrice, datas[index].low);
        }

        if (i >= period) {
          final double wr;
          if ((maxPrice - minPrice) == 0) {
            wr = 0;
          } else {
            wr = 100 * (maxPrice - datas[i].close) / (maxPrice - minPrice);
          }
          if (coverExist || !indicator.wr.containsKey(period)) {
            indicator.wr[period] = wr;
          }
          data.indicatorData.wr = indicator;
        }
      }
    }
  }
}
