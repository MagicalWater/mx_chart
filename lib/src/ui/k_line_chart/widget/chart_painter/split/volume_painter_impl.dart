import 'package:flutter/material.dart';

import '../../../model/model.dart';
import '../chart_painter.dart';
import '../impl/chart_painter_paint_mixin.dart';

export '../ui_style/k_line_chart_ui_style.dart';

class VolumePainterImpl extends ChartPainter with ChartPainterPaintMixin {
  VolumePainterImpl({
    required super.dataViewer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataViewer.volumeChartState.isNone) {
      return;
    }

    final chartRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 繪製成交量圖
    paintVolumeChart(canvas, chartRect);

    // 數值軸
    final rightValueRect = Rect.fromLTWH(
      size.width - dataViewer.chartUiStyle.sizeSetting.rightSpace,
      0,
      dataViewer.chartUiStyle.sizeSetting.rightSpace,
      size.height,
    );

    // 繪製數值軸
    paintValueAxisLine(canvas, rightValueRect);

    if (dataViewer.datas.isEmpty) {
      return;
    }

    // 繪製長按豎線
    paintLongPressCrossLine(canvas, chartRect);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
