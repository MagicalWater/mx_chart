import 'package:flutter/material.dart';

import '../../../chart_painter/data_viewer.dart';
import '../../scroll_bar_render.dart';
import '../main_chart/ui_style/main_chart_ui_style.dart';

export 'ui_style/macd_chart_ui_style.dart';

class ScrollBarBackgroundRenderImpl extends ScrollBarBackgroundRender {
  MainChartUiStyle get uiStyle => dataViewer.mainChartUiStyle;

  MainChartColorSetting get colors => uiStyle.colorSetting;

  final Paint backgroundPaint = Paint();
  final Paint gridPaint = Paint();

  ScrollBarBackgroundRenderImpl({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void initValue(Rect rect) {}

  @override
  void paintBackground(Canvas canvas, Rect rect) {
    backgroundPaint.color = colors.background;
    canvas.drawRect(rect, backgroundPaint);
  }

  @override
  void paintGrid(Canvas canvas, Rect rect) {
    final chartUiStyle = dataViewer.chartUiStyle;
    gridPaint.color = chartUiStyle.colorSetting.grid;
    gridPaint.strokeWidth = chartUiStyle.sizeSetting.gridLine;
    final gridColumns = chartUiStyle.sizeSetting.gridColumns;
    final contentWidth = rect.width - chartUiStyle.sizeSetting.rightSpace;
    final columnWidth = contentWidth / gridColumns;
    for (int i = 0; i <= gridColumns; i++) {
      final x = columnWidth * i;
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        gridPaint,
      );
    }
  }

  @override
  void paintChart(Canvas canvas, Rect rect) {}

  @override
  void paintRightValueText(Canvas canvas, Rect rect) {}

  @override
  void paintTopValueText(Canvas canvas, Rect rect) {}
}
