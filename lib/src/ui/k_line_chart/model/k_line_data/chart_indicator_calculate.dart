import 'dart:math';

import '../model.dart';

/// 圖表技術指標計算
class ChartIndicatorCalculator {
  /// 計算收盤價均線
  /// [period] - 週期, 默認為[5, 10, 20]
  static calculateMA({
    List<int> periods = const [5, 10, 20],
    required List<KLineData> datas,
  }) {
    var periodMaValue = List<double>.generate(periods.length, (index) => 0);

    for (var i = 0; i < datas.length; i++) {
      final indicator = IndicatorMa();
      final data = datas[i];
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

  /// 計算boll線
  /// [period] - 週期, 默認為20
  /// [bandwidth] - 帶寬
  static void calculateBOLL({
    int period = 20,
    int bandwidth = 2,
    required List<KLineData> datas,
  }) {
    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      // 先檢查是否有均線
      final indicatorMaValue = data.indicatorData.ma?.ma[period];
      if (indicatorMaValue == null) {
        continue;
      }

      double? mb, up, dn;
      if (i >= period) {
        double md = 0;
        for (var j = i - period + 1; j <= i; j++) {
          final c = datas[j].close;
          final value = c - indicatorMaValue;
          md += value * value;
        }
        md = md / (period - 1);
        md = sqrt(md);
        mb = indicatorMaValue;
        up = mb + bandwidth * md;
        dn = mb - bandwidth * md;

        data.indicatorData.boll = IndicatorBOLL(mb: mb, up: up, dn: dn);
      }
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

      data.indicatorData.macd = IndicatorMACD(
        dea: dea,
        dif: dif,
        macd: macd,
        emaShort: emaShort,
        emaLong: emaLong,
      );
    }
  }

  /// 計算相對強弱指標
  /// RSI (Relative Strength Index)
  /// [periods] - 週期, 默認為 [6, 12, 24]
  static void calculateRSI({
    List<int> periods = const [6, 12, 24],
    required List<KLineData> datas,
  }) {
    double rsi;
    var periodAbsEmaValue = List<double>.generate(periods.length, (index) => 0);
    var periodMaxEmaValue = List<double>.generate(periods.length, (index) => 0);

    for (var i = 1; i < datas.length; i++) {
      final indicator = IndicatorRSI();
      final data = datas[i];
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

        if (i < period || rsiAbsEma == 0) {
          rsi = 0;
        } else {
          rsi = (rsiMaxEma / rsiAbsEma) * 100;
        }

        indicator.rsi[period] = rsi;
      }

      data.indicatorData.rsi = indicator;
    }
  }

  /// 計算隨機指標
  /// 計算說明
  /// 在計算KDJ指標前，得先計算出「未成熟隨機值RSV」
  /// 就是一段期間內最終日收盤價減去期間內最低價的差額，佔當期內最高價與最低價差額的比例，再乘以100，而這個時間大多以9天為計算期。
  /// RSV = ((收盤價 - 週期內最低價) / (週期內最高價 - 週期內最低價)) * 100
  ///
  /// 接著可以計算K值
  /// K = (((K週期-1)/K值週期1) * (前日K值)) + ((1/K值週期) * RSV)
  ///
  /// 再由K值計算D值
  /// D = (((J值週期-1)/J值週期) * (前日D值)) + ((1/J值週期) * K)
  ///
  /// 如果沒有前一日的K值與D值, 則分別可用50替代
  /// 其中((週期-1)/週期)與(1/週期)為平滑因數, 可以人為選定, 但目前市面上已約定俗成
  /// 沒有特別需要改變的需要
  ///
  /// 最終計算出J值(大多為 3K - 2D, 部分使用 2D-3K, 其實只是翻轉了J值, 沒太多用途)
  /// J = (3 * K) - (2 * D)
  ///
  /// [period] - 計算RSV的週期(週期內最低/最高)
  /// [maPeriod1] - K值時間週期
  /// [maPeriod2] - J值移動平均時間週期
  static void calculateKDJ({
    int period = 9,
    int maPeriod1 = 3,
    int maPeriod2 = 3,
    required List<KLineData> datas,
  }) {
    double k = 0;
    double d = 0;

    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      final closePrice = data.close;
      int startIndex = i - 13;
      if (startIndex < 0) {
        startIndex = 0;
      }
      var maxPrice = -double.maxFinite;
      var minPrice = double.maxFinite;
      for (var index = startIndex; index <= i; index++) {
        maxPrice = max(maxPrice, datas[index].high);
        minPrice = min(minPrice, datas[index].low);
      }

      double rsv;
      if (maxPrice == minPrice) {
        rsv = 0;
      } else {
        rsv = ((closePrice - minPrice) / (maxPrice - minPrice)) * 100;
      }

      if (i == 0) {
        // 第一日沒有K值與D值, 因此賦值50
        k = 50;
        d = 50;
      } else {
        k = (((maPeriod1 - 1) / maPeriod1) * k) + ((1 / maPeriod1) * rsv);
        d = (((maPeriod2 - 1) / maPeriod2) * d) + ((1 / maPeriod2) * k);
      }

      if (i == period - 1 || i == period) {
        data.indicatorData.kdj = IndicatorKDJ(k: k, d: 0, j: 0);
      } else if (i > 14) {
        final j = (3 * k) - (2 * d);
        data.indicatorData.kdj = IndicatorKDJ(k: k, d: d, j: j);
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
  }) {
    for (var i = 0; i < datas.length; i++) {
      final indicator = IndicatorWR();

      final data = datas[i];

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
}
