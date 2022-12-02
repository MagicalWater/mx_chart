import 'package:flutter/material.dart';

import '../../../chart_painter/data_viewer.dart';
import '../../volume_chart_render.dart';
import 'volume_chart_render_value_mixin.dart';

export 'ui_style/volume_chart_ui_style.dart';

class VolumeChartRenderImpl extends VolumeChartRender
    with VolumeChartValueMixin {
  VolumeChartRenderImpl({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paintBackground(Canvas canvas, Rect rect) {
    backgroundPaint.color = colors.background;
    canvas.drawRect(rect, backgroundPaint);
  }

  @override
  void paintChart(Canvas canvas, Rect rect) {
    // 長柱的寬度半徑
    final barWidthRadius = barWidthScaled / 2;

    for (int i = dataViewer.startDataIndex; i <= dataViewer.endDataIndex; i++) {
      final data = dataViewer.datas[i];
      final x = dataViewer.dataIndexToRealX(i);

      // 是否漲
      final isUp = data.close > data.open;

      // 柱子的顏色
      final color = isUp ? colors.barUp : colors.barDown;

      chartPaint.color = color;

      // 取得成交量對應的y軸
      final y = valueToRealY(data.volume.toDouble());
      canvas.drawRect(
        Rect.fromLTRB(x - barWidthRadius, y, x + barWidthRadius, maxY),
        chartPaint,
      );
    }
  }

  @override
  void paintGrid(Canvas canvas, Rect rect) {
    final chartUiStyle = dataViewer.chartUiStyle;
    gripPaint.color = chartUiStyle.colorSetting.grid;
    final gridColumns = chartUiStyle.sizeSetting.gridColumns;
    final contentWidth = rect.width - chartUiStyle.sizeSetting.rightSpace;
    final columnWidth = contentWidth / gridColumns;
    for (int i = 0; i <= gridColumns; i++) {
      final x = columnWidth * i;
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        gripPaint,
      );
    }
  }

  @override
  void paintRightValueText(Canvas canvas, Rect rect) {
    // 只繪製最大值, 因為最小為0不用特別繪製
    final textStyle = TextStyle(
      color: colors.rightMaxValueText,
      fontSize: sizes.rightMaxValueText,
    );
    final textSpan = TextSpan(
      text: dataViewer.volumeFormatter(maxValue),
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.width - textPainter.width, rect.top),
    );
  }

  @override
  void paintTopValueText(Canvas canvas, Rect rect) {
    final displayData = dataViewer.getLongPressData() ?? dataViewer.datas.last;
    final textStyle = TextStyle(
      fontSize: sizes.indexTip,
      color: colors.indexTip,
    );
    final textSpan = TextSpan(
      text: 'VOL:${dataViewer.volumeFormatter(displayData.volume)}',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(5, rect.top),
    );
  }
}
