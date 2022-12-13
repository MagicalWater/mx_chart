import 'dart:math';

import '../ui/k_line_chart/model/model.dart';

/// 圖表技術指標計算
class BollCalculator {
  /// 計算boll線
  /// [period] - 週期, 默認為20
  /// [bandwidth] - 帶寬
  static void calculateBollAtLast({
    int period = 20,
    int bandwidth = 2,
    required List<KLineData> oriData,
    required List<KLineData> newData,
  }) {
    final datas = [...oriData, ...newData];
    final startIndex = oriData.length;
    for (var i = startIndex; i < datas.length; i++) {
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

  /// 計算boll線
  /// [period] - 週期, 默認為20
  /// [bandwidth] - 帶寬
  static void calculateBOLLAtFirst({
    int period = 20,
    int bandwidth = 2,
    required List<KLineData> oriData,
    required List<KLineData> newData,
  }) {
    final newDataLength = newData.length;

    for (var i = 0; i < newData.length; i++) {
      final data = newData[i];
      // 先檢查是否有均線
      final indicatorMaValue = data.indicatorData.ma?.ma[period];
      if (indicatorMaValue == null) {
        continue;
      }

      double? mb, up, dn;
      if (i >= period) {
        double md = 0;
        for (var j = i - period + 1; j <= i; j++) {
          final c = newData[j].close;
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

    for (var i = 0; i < oriData.length; i++) {
      final data = oriData[i];

      // 檢查是否已有資料, 若已有資料則停止
      if (data.indicatorData.boll != null) {
        return;
      }

      // 檢查是否有均線
      final indicatorMaValue = data.indicatorData.ma?.ma[period];
      if (indicatorMaValue == null) {
        continue;
      }

      final dataIndex = newDataLength + i;

      double? mb, up, dn;
      if (dataIndex >= period) {
        double md = 0;
        for (var j = i - period + 1; j <= i; j++) {
          final double c;
          if (j < 0) {
            c = newData[newDataLength + dataIndex].close;
          } else {
            c = oriData[j].close;
          }
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
}
