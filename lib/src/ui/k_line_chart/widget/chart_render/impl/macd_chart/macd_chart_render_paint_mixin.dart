import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../model/k_line_data/indicator/indicator.dart';
import 'macd_chart_render_value_mixin.dart';

mixin MACDChartRenderPaintMixin on MACDChartValueMixin {
  /// 繪製dif/dea線
  void paintDifDeaChart(Canvas canvas, Rect rect) {
    linePaint.strokeWidth = sizes.lineWidth;

    final macdData = dataViewer.datas.map((e) => e.indicatorData.macd);

    // 繪dif線
    final difList = macdData.map((e) => e?.dif).toList();
    final difPath = _getDisplayLinePath(difList, curve: false);
    linePaint.color = colors.difColor;
    canvas.drawPath(difPath, linePaint);

    // 繪dea線
    final deaList = macdData.map((e) => e?.dea).toList();
    final deaPath = _getDisplayLinePath(deaList, curve: false);
    linePaint.color = colors.deaColor;
    canvas.drawPath(deaPath, linePaint);
  }

  /// 取得顯示在螢幕上的路線Path
  /// [curve] - 是否使用曲線
  Path _getDisplayLinePath(List<double?> values, {bool curve = true}) {
    final linePath = Path();

    double? preValue;
    double? preX, preY;

    final startIndex = max(0, dataViewer.startDataIndex - 1);
    final endIndex = min(
      values.length - 1,
      dataViewer.endDataIndex + 1,
    );

    // 畫折線
    for (int i = startIndex; i <= endIndex; i++) {
      final value = values[i];
      if (value == null) {
        continue;
      }
      final x = dataViewer.dataIndexToRealX(i);
      final y = valueToRealY(value);

      if (preValue == null) {
        linePath.moveTo(x, y);
      } else {
        final centerX = (preX! + x) / 2;
        if (curve) {
          linePath.cubicTo(centerX, preY!, centerX, y, x, y);
        } else {
          linePath.lineTo(x, y);
        }
      }

      preX = x;
      preY = y;
      preValue = value;
    }

    return linePath;
  }

  /// 繪製長柱圖
  void paintBarChart(Canvas canvas, Rect rect) {
    // 長柱的寬度半徑
    final barWidthRadius = barWidthScaled / 2;
    IndicatorMACD? preMaData;

    // 數值為0的y軸位置
    final zeroY = valueToRealY(0);

    for (var i = dataViewer.startDataIndex; i <= dataViewer.endDataIndex; i++) {
      final data = dataViewer.datas[i];
      final x = dataViewer.dataIndexToRealX(i);
      final macdData = data.indicatorData.macd;
      if (macdData == null) {
        continue;
      }

      final y = valueToRealY(macdData.macd);

      if (macdData.macd > 0) {
        // 正向長柱
        final Color barColor;
        if (preMaData == null || macdData.macd >= preMaData.macd) {
          // 正向上漲長柱
          barColor = colors.positiveUpColor;
        } else {
          // 正向下跌長柱
          barColor = colors.positiveDownColor;
        }
        canvas.drawRect(
          Rect.fromLTRB(x - barWidthRadius, y, x + barWidthRadius, zeroY),
          chartPaint..color = barColor,
        );
      } else {
        // 負向長柱
        final Color barColor;
        if (preMaData == null || macdData.macd >= preMaData.macd) {
          // 負向上漲長柱
          barColor = colors.negativeUpColor;
        } else {
          // 負向下跌長柱
          barColor = colors.negativeDownColor;
        }
        canvas.drawRect(
          Rect.fromLTRB(x - barWidthRadius, zeroY, x + barWidthRadius, y),
          chartPaint..color = barColor,
        );
      }

      preMaData = macdData;
    }
  }
}
