import 'dart:math';

import 'package:flutter/material.dart';

import 'wr_chart_render_value_mixin.dart';

mixin WRChartRenderPaintMixin on WRChartValueMixin {
  /// 繪製wr線
  void paintWRChart(Canvas canvas, Rect rect) {
    linePaint.strokeWidth = sizes.lineWidth;

    final wrData = dataViewer.datas.map((e) => e.indicatorData.wr?.wr);
    final periods = dataViewer.indicatorSetting.wrSetting.periods;

    var index = 0;
    for (final element in periods) {
      final wrList = wrData.map((e) => e?[element]).toList();
      final linePath = _getDisplayLinePath(wrList, curve: false);
      linePaint.color = colors.wrLine[index];
      canvas.drawPath(linePath, linePaint);
      index++;
    }
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
