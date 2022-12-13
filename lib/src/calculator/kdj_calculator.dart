import 'dart:math';

import '../ui/k_line_chart/model/model.dart';

/// 圖表技術指標計算
class KdjCalculator {

  static void calculateKDJAtLast({
    int period = 9,
    int maPeriod1 = 3,
    int maPeriod2 = 3,
    required List<KLineData> oriData,
    required List<KLineData> newData,
  }) {
    final datas = [...oriData, ...newData];

    final startIndex = oriData.length;

    final oriLastData = oriData.last.indicatorData.kdj;
    double k = oriLastData?.k ?? 0;
    double d = oriLastData?.d ?? 0;

    for (var i = startIndex; i < datas.length; i++) {
      final data = datas[i];
      final closePrice = data.close;
      int startIndex = i - (period - 1);
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
      } else if (i > period) {
        final j = (3 * k) - (2 * d);
        data.indicatorData.kdj = IndicatorKDJ(k: k, d: d, j: j);
      }
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
      int startIndex = i - (period - 1);
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
      } else if (i > period) {
        final j = (3 * k) - (2 * d);
        data.indicatorData.kdj = IndicatorKDJ(k: k, d: d, j: j);
      }
    }
  }
}
