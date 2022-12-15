import 'dart:math';

import '../ui/k_line_chart/model/model.dart';

/// 圖表技術指標計算
class RsiCalculator {
  static void calculateRsiAtLast({
    List<int> periods = const [6, 12, 24],
    required List<KLineData> oriData,
    required List<KLineData> newData,
  }) {
    final datas = [...oriData, ...newData];
    final startIndex = oriData.length;

    final oriLastData = oriData.last.indicatorData.rsi;

    var periodAbsEmaValue = List<double>.generate(
      periods.length,
      (index) => oriLastData?.rsiABSEma[periods[index]] ?? 0,
    );
    var periodMaxEmaValue = List<double>.generate(
      periods.length,
      (index) => oriLastData?.rsiMaxEma[periods[index]] ?? 0,
    );

    double rsi;

    for (var i = startIndex; i < datas.length; i++) {
      final data = datas[i];
      final indicator = data.indicatorData.rsi ?? IndicatorRSI();
      final close = data.close;
      final rMax = max(0, close - datas[i - 1].close);
      final rAbs = (close - datas[i - 1].close).abs();

      for (var j = 0; j < periods.length; j++) {
        final period = periods[j];
        var rsiMaxEma = periodMaxEmaValue[j];
        var rsiAbsEma = periodAbsEmaValue[j];

        periodMaxEmaValue[j] = (rMax + (period - 1) * rsiMaxEma) / period;
        periodAbsEmaValue[j] = (rAbs + (period - 1) * rsiAbsEma) / period;

        rsiMaxEma = periodMaxEmaValue[j];
        rsiAbsEma = periodAbsEmaValue[j];

        if (i >= period && rsiAbsEma != 0) {
          rsi = (rsiMaxEma / rsiAbsEma) * 100;
          if (rsi.isNaN) {
            rsi = 0;
          }
          indicator.rsi[period] = rsi;
          indicator.rsiMaxEma[period] = rsiMaxEma;
          indicator.rsiABSEma[period] = rsiAbsEma;
        }
      }

      data.indicatorData.rsi = indicator;
    }
  }

  /// 計算相對強弱指標
  /// RSI (Relative Strength Index)
  /// [periods] - 週期, 默認為 [6, 12, 24]
  static void calculateRSI({
    List<int> periods = const [6, 12, 24],
    required List<KLineData> datas,
    bool coverExist = true,
  }) {
    double rsi;
    var periodAbsEmaValue = List<double>.generate(periods.length, (index) => 0);
    var periodMaxEmaValue = List<double>.generate(periods.length, (index) => 0);

    for (var i = 1; i < datas.length; i++) {
      final data = datas[i];
      final indicator = data.indicatorData.rsi ?? IndicatorRSI();
      final close = data.close;
      final rMax = max(0, close - datas[i - 1].close);
      final rAbs = (close - datas[i - 1].close).abs();

      for (var j = 0; j < periods.length; j++) {
        final period = periods[j];
        var rsiMaxEma = periodMaxEmaValue[j];
        var rsiAbsEma = periodAbsEmaValue[j];

        periodMaxEmaValue[j] = (rMax + (period - 1) * rsiMaxEma) / period;
        periodAbsEmaValue[j] = (rAbs + (period - 1) * rsiAbsEma) / period;

        rsiMaxEma = periodMaxEmaValue[j];
        rsiAbsEma = periodAbsEmaValue[j];

        if (i >= period && rsiAbsEma != 0) {
          rsi = (rsiMaxEma / rsiAbsEma) * 100;
          if (rsi.isNaN) {
            rsi = 0;
          }
          if (coverExist || !indicator.rsi.containsKey(period)) {
            indicator.rsi[period] = rsi;
          }
        }
      }

      data.indicatorData.rsi = indicator;
    }
  }
}
