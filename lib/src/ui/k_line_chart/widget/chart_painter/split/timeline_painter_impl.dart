import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/k_line_chart/model/model.dart';

import '../chart_painter.dart';
import '../impl/chart_painter_paint_mixin.dart';

export '../ui_style/k_line_chart_ui_style.dart';

class TimelinePainterImpl extends ChartPainter
    with ChartPainterPaintMixin {
  TimelinePainterImpl({
    required super.dataViewer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataViewer.mainChartState.isNone &&
        dataViewer.volumeChartState.isNone &&
        dataViewer.indicatorChartState.isNone) {
      return;
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 繪製時間軸
    paintTimeAxis(canvas, rect);

    // 繪製長按時間
    paintLongPressTime(canvas, rect);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
