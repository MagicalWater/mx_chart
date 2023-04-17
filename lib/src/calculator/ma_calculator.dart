import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

import '../ui/k_line_chart/model/model.dart';

/// 圖表技術指標計算
class MaCalculator {
  /// 計算收盤價均線
  /// [newData] - 即將插入到[oriData]之後的資料
  /// [period] - 週期, 默認為[5, 10, 20]
  static void calculateMaAtLast({
    List<int> periods = const [5, 10, 20],
    required List<KLineData> oriData,
    required List<KLineData> newData,
  }) {
    final oriMa = oriData.lastOrNull?.indicatorData.ma?.ma;
    if (oriMa == null ||
        periods.any((element) => !oriMa.containsKey(element))) {
      if (kDebugMode) {
        print(
            'MaCalculator(MaLast): 原始資料的ma技術線不完整, 無法使用atLast方式計算技術線');
      }
      return;
    }

    final datas = [...oriData, ...newData];
    final startIndex = oriData.length;

    var periodMaValue = List<double>.generate(periods.length, (index) {
      final period = periods[index];
      return oriMa[period]! * period;
    });

    for (var i = startIndex; i < datas.length; i++) {
      final data = datas[i];
      final indicator = data.indicatorData.ma ?? IndicatorMa();
      final close = data.close;

      periodMaValue = periodMaValue.map((e) => e + close).toList();

      for (var j = 0; j < periods.length; j++) {
        final period = periods[j];
        var value = periodMaValue[j];
        if (i == period - 1) {
          indicator.ma[period] = value / period;
        } else if (i >= period) {
          final removeValue = datas[i - period].close;
          value -= removeValue;
          periodMaValue[j] = value;
          indicator.ma[period] = value / period;
        }
      }

      data.indicatorData.ma = indicator;
    }
  }

  /// 計算收盤價均線
  /// [newData] - 即將插入到[oriData]之前的資料
  /// [period] - 週期, 默認為[5, 10, 20]
  static void calculateMaAtFirst({
    List<int> periods = const [5, 10, 20],
    required List<KLineData> oriData,
    required List<KLineData> newData,
  }) {
    var periodMaValue = List<double>.generate(periods.length, (index) => 0);

    for (var i = 0; i < newData.length; i++) {
      final data = newData[i];
      final indicator = data.indicatorData.ma ?? IndicatorMa();
      final close = data.close;

      periodMaValue = periodMaValue.map((e) => e + close).toList();

      for (var j = 0; j < periods.length; j++) {
        final period = periods[j];
        var value = periodMaValue[j];
        if (i == period - 1) {
          indicator.ma[period] = value / period;
        } else if (i >= period) {
          final removeValue = newData[i - period].close;
          value -= removeValue;
          periodMaValue[j] = value;
          indicator.ma[period] = value / period;
        }
      }

      data.indicatorData.ma = indicator;
    }

    final newDataLength = newData.length;

    for (var i = 0; i < oriData.length; i++) {
      final oriMa = oriData[i].indicatorData.ma?.ma;

      if (oriMa == null ||
          periods.any((element) => !oriMa.containsKey(element))) {
        // 資料不完整, 繼續
        final indicator = IndicatorMa();
        final data = oriData[i];
        final close = data.close;

        periodMaValue = periodMaValue.map((e) => e + close).toList();

        for (var j = 0; j < periods.length; j++) {
          final period = periods[j];
          var value = periodMaValue[j];

          final index = i + newDataLength;

          if (index == period - 1) {
            indicator.ma[period] = value / period;
          } else if (index >= period) {
            final removeIndex = i - period;
            double removeValue;
            if (removeIndex < 0) {
              removeValue = newData[newDataLength + removeIndex].close;
            } else {
              removeValue = oriData[removeIndex].close;
            }
            value -= removeValue;
            periodMaValue[j] = value;
            indicator.ma[period] = value / period;
          }
        }

        data.indicatorData.ma = indicator;
      } else {
        // 資料完整, 停止
        return;
      }
    }
  }

  /// 計算收盤價均線
  /// [period] - 週期, 默認為[5, 10, 20]
  static calculateMA({
    List<int> periods = const [5, 10, 20],
    required List<KLineData> datas,
  }) {
    var periodMaValue = List<double>.generate(periods.length, (index) => 0);

    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      final indicator = data.indicatorData.ma ?? IndicatorMa();
      final close = data.close;

      periodMaValue = periodMaValue.map((e) => e + close).toList();

      for (var j = 0; j < periods.length; j++) {
        final period = periods[j];
        var value = periodMaValue[j];
        if (i == period - 1) {
          indicator.ma[period] = value / period;
        } else if (i >= period) {
          final removeValue = datas[i - period].close;
          value -= removeValue;
          periodMaValue[j] = value;
          indicator.ma[period] = value / period;
        }
      }

      data.indicatorData.ma = indicator;
    }
  }
}
