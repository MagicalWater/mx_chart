import 'dart:math';

import 'package:flutter/material.dart';

import 'kdj_chart_render_value_mixin.dart';

mixin KDJChartRenderPaintMixin on KDJChartValueMixin {
  /// 繪製k/d/j線
  void paintKDJChart(Canvas canvas, Rect rect) {
    linePaint.strokeWidth = sizes.lineWidth;

    final kdjData = dataViewer.datas.map((e) => e.indicatorData.kdj);

    // 繪k線
    final kList = kdjData.map((e) => e?.k).toList();
    final kPath = _getDisplayLinePath(kList, curve: false);
    linePaint.color = colors.kColor;
    canvas.drawPath(kPath, linePaint);

    // 繪d線
    final dList = kdjData.map((e) => e?.d).toList();
    final dPath = _getDisplayLinePath(dList, curve: false);
    linePaint.color = colors.dColor;
    canvas.drawPath(dPath, linePaint);

    // 繪j線
    final jList = kdjData.map((e) => e?.j).toList();
    final jPath = _getDisplayLinePath(jList, curve: false);
    linePaint.color = colors.jColor;
    canvas.drawPath(jPath, linePaint);
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
}
