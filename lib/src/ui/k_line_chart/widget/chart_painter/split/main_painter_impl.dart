import 'package:flutter/material.dart';

import '../../../model/model.dart';
import '../chart_painter.dart';
import '../impl/chart_painter_paint_mixin.dart';

export '../ui_style/k_line_chart_ui_style.dart';

class MainPainterImpl extends ChartPainter
    with ChartPainterPaintMixin {
  /// 在父元件的偏移位置
  final Offset Function() localPosition;

  /// 價格標示y軸位置獲取
  ChartPositionGetter? chartPositionGetter;

  MainPainterImpl({
    required super.dataViewer,
    required this.localPosition,
    this.chartPositionGetter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataViewer.mainChartState.isNone) {
      return;
    }

    final chartRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 繪製主圖
    paintMainChart(
      canvas: canvas,
      rect: chartRect,
      pricePositionGetter: chartPositionGetter,
      localPosition: localPosition,
    );

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
