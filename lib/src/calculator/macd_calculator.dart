import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../ui/k_line_chart/model/model.dart';

/// 圖表技術指標計算
class MacdCalculator {
  /// 計算指數平滑異同移動平均線
  /// 使用兩條不同速度的ema線算出差離值(dif)
  /// 對差離值再進行一次移動平均線的計算
  /// [shortPeriod] - 週期較短的ema週期, 默認為12
  /// [longPeriod] - 週期較長的ema週期, 默認為26
  /// [difPeriod] - 差離值計算平均線的週期, 默認為9
  static void calculateMacdAtLast({
    int shortPeriod = 12,
    int longPeriod = 26,
    int difPeriod = 9,
    required List<KLineData> oriData,
    required List<KLineData> newData,
  }) {
    final datas = [...oriData, ...newData];
    final startIndex = oriData.length;

    final oriMacd = oriData.lastOrNull?.indicatorData.macd;
    if (oriMacd == null) {
      if (kDebugMode) {
        print('MaCalculator(MacdLast): 原始資料的macd技術線不完整, 無法使用atLast方式計算技術線');
      }
      return;
    }

    double emaShort = oriMacd.emaShort;
    double emaLong = oriMacd.emaLong;

    // 差離值(快線)
    double dif = oriMacd.dif;

    // 慢線
    double dea = oriMacd.dea;

    // macd數值(柱狀圖)
    double macd = oriMacd.macd;

    for (var i = startIndex; i < datas.length; i++) {
      final data = datas[i];
      final close = data.close;
      if (i == 0) {
        emaShort = close;
        emaLong = close;
      } else {
        // EMA(n)=(前一日EMA(n) × (n-1)+今日收盤價 × 2) ÷ (n+1)
        emaShort =
            (emaShort * (shortPeriod - 1) + close * 2) / (shortPeriod + 1);
        // EMA(m)=(前一日EMA(m) × (m-1)+今日收盤價 × 2) ÷ (m+1)
        emaLong = (emaLong * (longPeriod - 1) + close * 2) / (longPeriod + 1);
      }
      // DIF=EMA(n)－EMA(m)
      dif = emaShort - emaLong;

      // DEA(k)=(前一日DEA x (k-1)/(k+1) + 今日DIF x 2/(k+1))
      dea = dea * (difPeriod - 1) / (difPeriod + 1) + dif * 2 / (difPeriod + 1);

      // MACD(k)=(今日DIF - 今日DEA) x 2
      macd = (dif - dea) * 2;

      data.indicatorData.macd = IndicatorMACD(
        dea: dea,
        dif: dif,
        macd: macd,
        emaShort: emaShort,
        emaLong: emaLong,
      );
    }
  }

  /// 計算指數平滑異同移動平均線
  /// 使用兩條不同速度的ema線算出差離值(dif)
  /// 對差離值再進行一次移動平均線的計算
  /// [shortPeriod] - 週期較短的ema週期, 默認為12
  /// [longPeriod] - 週期較長的ema週期, 默認為26
  /// [difPeriod] - 差離值計算平均線的週期, 默認為9
  static void calculateMacdAtFirst({
    int shortPeriod = 12,
    int longPeriod = 26,
    int difPeriod = 9,
    required List<KLineData> oriData,
    required List<KLineData> newData,
  }) {
    double emaShort = 0;
    double emaLong = 0;

    // 差離值(快線)
    double dif = 0;

    // 慢線
    double dea = 0;

    // macd數值(柱狀圖)
    double macd = 0;

    for (var i = 0; i < newData.length; i++) {
      final data = newData[i];
      final close = data.close;
      if (i == 0) {
        emaShort = close;
        emaLong = close;
      } else {
        // EMA(n)=(前一日EMA(n) × (n-1)+今日收盤價 × 2) ÷ (n+1)
        emaShort =
            (emaShort * (shortPeriod - 1) + close * 2) / (shortPeriod + 1);
        // EMA(m)=(前一日EMA(m) × (m-1)+今日收盤價 × 2) ÷ (m+1)
        emaLong = (emaLong * (longPeriod - 1) + close * 2) / (longPeriod + 1);
      }
      // DIF=EMA(n)－EMA(m)
      dif = emaShort - emaLong;

      // DEA(k)=(前一日DEA x (k-1)/(k+1) + 今日DIF x 2/(k+1))
      dea = dea * (difPeriod - 1) / (difPeriod + 1) + dif * 2 / (difPeriod + 1);

      // MACD(k)=(今日DIF - 今日DEA) x 2
      macd = (dif - dea) * 2;

      data.indicatorData.macd = IndicatorMACD(
        dea: dea,
        dif: dif,
        macd: macd,
        emaShort: emaShort,
        emaLong: emaLong,
      );
    }

    for (var i = 0; i < oriData.length; i++) {
      final data = oriData[i];
      final close = data.close;

      // EMA(n)=(前一日EMA(n) × (n-1)+今日收盤價 × 2) ÷ (n+1)
      emaShort = (emaShort * (shortPeriod - 1) + close * 2) / (shortPeriod + 1);
      // EMA(m)=(前一日EMA(m) × (m-1)+今日收盤價 × 2) ÷ (m+1)
      emaLong = (emaLong * (longPeriod - 1) + close * 2) / (longPeriod + 1);

      // DIF=EMA(n)－EMA(m)
      dif = emaShort - emaLong;

      // DEA(k)=(前一日DEA x (k-1)/(k+1) + 今日DIF x 2/(k+1))
      dea = dea * (difPeriod - 1) / (difPeriod + 1) + dif * 2 / (difPeriod + 1);

      // MACD(k)=(今日DIF - 今日DEA) x 2
      macd = (dif - dea) * 2;

      data.indicatorData.macd = IndicatorMACD(
        dea: dea,
        dif: dif,
        macd: macd,
        emaShort: emaShort,
        emaLong: emaLong,
      );
    }
  }

  /// 計算指數平滑異同移動平均線
  /// 使用兩條不同速度的ema線算出差離值(dif)
  /// 對差離值再進行一次移動平均線的計算
  /// [shortPeriod] - 週期較短的ema週期, 默認為12
  /// [longPeriod] - 週期較長的ema週期, 默認為26
  /// [difPeriod] - 差離值計算平均線的週期, 默認為9
  static void calculateMACD({
    int shortPeriod = 12,
    int longPeriod = 26,
    int difPeriod = 9,
    required List<KLineData> datas,
    bool coverExist = true,
  }) {
    double emaShort = 0;
    double emaLong = 0;

    // 差離值(快線)
    double dif = 0;

    // 慢線
    double dea = 0;

    // macd數值(柱狀圖)
    double macd = 0;

    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      final close = data.close;
      if (i == 0) {
        emaShort = close;
        emaLong = close;
      } else {
        // EMA(n)=(前一日EMA(n) × (n-1)+今日收盤價 × 2) ÷ (n+1)
        emaShort =
            (emaShort * (shortPeriod - 1) + close * 2) / (shortPeriod + 1);
        // EMA(m)=(前一日EMA(m) × (m-1)+今日收盤價 × 2) ÷ (m+1)
        emaLong = (emaLong * (longPeriod - 1) + close * 2) / (longPeriod + 1);
      }
      // DIF=EMA(n)－EMA(m)
      dif = emaShort - emaLong;

      // DEA(k)=(前一日DEA x (k-1)/(k+1) + 今日DIF x 2/(k+1))
      dea = dea * (difPeriod - 1) / (difPeriod + 1) + dif * 2 / (difPeriod + 1);

      // MACD(k)=(今日DIF - 今日DEA) x 2
      macd = (dif - dea) * 2;

      if (coverExist || data.indicatorData.macd == null) {
        data.indicatorData.macd = IndicatorMACD(
          dea: dea,
          dif: dif,
          macd: macd,
          emaShort: emaShort,
          emaLong: emaLong,
        );
      }
    }
  }
}
