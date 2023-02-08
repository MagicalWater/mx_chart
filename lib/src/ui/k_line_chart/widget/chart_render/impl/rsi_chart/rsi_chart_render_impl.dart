import 'package:flutter/material.dart';
import 'package:mx_chart/src/extension/extension.dart';

import '../../../chart_painter/data_viewer.dart';
import '../../rsi_chart_render.dart';
import 'rsi_chart_render_paint_mixin.dart';
import 'rsi_chart_render_value_mixin.dart';

export 'ui_style/rsi_chart_ui_style.dart';

class RSIChartRenderImpl extends RSIChartRender
    with RSIChartValueMixin, RSIChartRenderPaintMixin {
  RSIChartRenderImpl({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paintBackground(Canvas canvas, Rect rect) {
    backgroundPaint.color = colors.background;
    canvas.drawRect(rect, backgroundPaint);
  }

  @override
  void paintChart(Canvas canvas, Rect rect) {
    // 繪製rsi線圖
    paintRSIChart(canvas, rect);
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
  void paintRightValueText(Canvas canvas, Rect rect) {
    final textStyle = TextStyle(
      color: colors.rightValueText,
      fontSize: sizes.rightValueText,
    );
    final maxValueSpan = TextSpan(
      text: dataViewer.priceFormatter(maxValue),
      style: textStyle,
    );

    // 畫最大值
    final textPainter = TextPainter(
      text: maxValueSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.width - textPainter.width, rect.top),
    );

    // 畫最小值
    final minValueSpan = TextSpan(
      text: dataViewer.priceFormatter(minValue),
      style: textStyle,
    );
    textPainter.text = minValueSpan;
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.width - textPainter.width,
          rect.bottom - textPainter.height - sizes.bottomPadding),
    );
  }

  @override
  void paintTopValueText(Canvas canvas, Rect rect) {
    final displayData = dataViewer.getLongPressData() ?? dataViewer.datas.last;
    final rsiData = displayData.indicatorData.rsi?.rsi;

    if (rsiData == null || rsiData.isEmpty) {
      return;
    }

    final textStyle = TextStyle(fontSize: sizes.indexTip);

    final spanTexts = <TextSpan>[];

    final rsiSpan = dataViewer.indicatorSetting.rsiSetting.periods
        .indexMap((e, i) {
          final value = rsiData[e];
          if (value == null || value == 0) {
            return null;
          }
          return TextSpan(
            text: 'RSI($e):${dataViewer.priceFormatter(value)}  ',
            style: textStyle.copyWith(color: colors.rsiLine[i]),
          );
        })
        .whereType<TextSpan>()
        .toList();

    spanTexts.addAll(rsiSpan);

    final textPainter = TextPainter(
      text: TextSpan(children: spanTexts),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, rect.top));
  }
}
