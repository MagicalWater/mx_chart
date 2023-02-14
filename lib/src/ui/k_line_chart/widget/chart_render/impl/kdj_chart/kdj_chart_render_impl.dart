import 'package:flutter/material.dart';

import '../../../chart_painter/data_viewer.dart';
import '../../kdj_chart_render.dart';
import 'kdj_chart_render_paint_mixin.dart';
import 'kdj_chart_render_value_mixin.dart';

export 'ui_style/kdj_chart_ui_style.dart';

class KDJChartRenderImpl extends KDJChartRender
    with KDJChartValueMixin, KDJChartRenderPaintMixin {
  KDJChartRenderImpl({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paintBackground(Canvas canvas, Rect rect) {
    backgroundPaint.color = colors.background;
    canvas.drawRect(rect, backgroundPaint);
  }

  @override
  void paintChart(Canvas canvas, Rect rect) {
    // 繪製k/d/j線圖
    paintKDJChart(canvas, rect);
  }

  @override
  void paintGrid(Canvas canvas, Rect rect) {
    if (!uiStyle.gridEnabled) {
      return;
    }
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
  void paintDivider(Canvas canvas, Rect rect) {
    final rightSpace = dataViewer.chartUiStyle.sizeSetting.rightSpace;
    final rectTop = rect.top;
    final rectBottom = rect.bottom;

    // 繪製頂部分隔線
    if (sizes.topDivider != 0) {
      gridPaint.strokeWidth = sizes.topDivider;
      canvas.drawLine(
        Offset(0, rectTop),
        Offset(rect.width - rightSpace, rectTop),
        gridPaint..color = colors.topDivider,
      );
    }

    // 繪製底部分隔線
    if (sizes.bottomDivider != 0) {
      gridPaint.strokeWidth = sizes.bottomDivider;
      canvas.drawLine(
        Offset(0, rectBottom),
        Offset(rect.width - rightSpace, rectBottom),
        gridPaint..color = colors.bottomDivider,
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
    final kdjData = displayData.indicatorData.kdj;

    if (kdjData == null) {
      return;
    }

    final indicatorSetting = dataViewer.indicatorSetting;
    final period = indicatorSetting.kdjSetting.period;
    final maPeriod1 = indicatorSetting.kdjSetting.maPeriod1;
    final maPeriod2 = indicatorSetting.kdjSetting.maPeriod2;

    final textStyle = TextStyle(fontSize: sizes.indexTip);

    final spans = <TextSpan>[
      TextSpan(
        text: 'KDJ($period,$maPeriod1,$maPeriod2)  ',
        style: textStyle.copyWith(color: colors.kdjTip),
      ),
      if (kdjData.k != 0)
        TextSpan(
          text: 'K:${dataViewer.priceFormatter(kdjData.k)}  ',
          style: textStyle.copyWith(color: colors.kColor),
        ),
      if (kdjData.d != 0)
        TextSpan(
          text: 'D:${dataViewer.priceFormatter(kdjData.d)}  ',
          style: textStyle.copyWith(color: colors.dColor),
        ),
      if (kdjData.k != 0)
        TextSpan(
          text: 'J:${dataViewer.priceFormatter(kdjData.j)}  ',
          style: textStyle.copyWith(color: colors.jColor),
        ),
    ];

    final textPainter = TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, rect.top));
  }
}
