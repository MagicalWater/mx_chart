import 'package:flutter/material.dart';
import 'package:mx_chart/src/extension/extension.dart';

import '../../../../k_line_chart.dart';
import 'main_chart_render_paint_mixin.dart';
import 'main_chart_render_value_mixin.dart';

export 'ui_style/main_chart_ui_style.dart';

class MainChartRenderImpl extends MainChartRender
    with MainChartValueMixin, MainChartRenderPaintMixin {
  /// [pricePositionGetter] - 價格標示y軸位置獲取
  MainChartRenderImpl({
    required super.dataViewer,
    required super.localPosition,
    super.pricePositionGetter,
  });

  /// 繪製背景
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
    final topPadding = sizes.topPadding;
    final bottomPadding = sizes.bottomPadding;
    final contentHeight = rect.height - topPadding - bottomPadding;
    final contentWidth = rect.width - chartUiStyle.sizeSetting.rightSpace;
    final gridRows = chartUiStyle.sizeSetting.getRealRows(contentHeight);
    final rectTop = rect.top;

    // 每一列的高度
    final rowHeight = contentHeight / gridRows;

    // 每一行寬度
    final columnWidth = contentWidth / gridColumns;

    // 畫橫線
    for (int i = 0; i <= gridRows; i++) {
      final y = rowHeight * i + topPadding;
      canvas.drawLine(
        Offset(0, y + rectTop),
        Offset(rect.width, y + rectTop),
        gridPaint,
      );
    }

    // 畫直線
    for (var i = 1; i < gridColumns; i++) {
      final x = columnWidth * i;
      canvas.drawLine(
        Offset(x, (topPadding / 3) + rectTop),
        Offset(x, rect.bottom + rectTop),
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

  /// 繪製上方的數值說明文字
  @override
  void paintTopValueText(Canvas canvas, Rect rect) {
    final displayData = dataViewer.longPressData ?? dataViewer.datas.last;
    final maData = displayData.indicatorData.ma?.ma;
    final spanTexts = <TextSpan>[];

    // 檢查是否需要顯示ma資訊
    if (isShowMa) {
      final maTextStyle = TextStyle(fontSize: sizes.indexTip);
      final maSpan = dataViewer.indicatorSetting.maSetting.periods
          .indexMap((e, i) {
            final value = maData?[e];
            if (value == null || value == 0) {
              return null;
            }
            return TextSpan(
              text: 'MA($e):${dataViewer.priceFormatter(value)}  ',
              style: maTextStyle.copyWith(
                color: colors.maLine[i],
              ),
            );
          })
          .whereType<TextSpan>()
          .toList();
      spanTexts.addAll(maSpan);
    }

    // 檢查是否需要顯示boll訊息
    final bollData = displayData.indicatorData.boll;
    if (isShowBoll && bollData != null) {
      final bollTextStyle = TextStyle(fontSize: sizes.indexTip);

      final bollSpan = [
        TextSpan(
          text: 'BOLL:${dataViewer.priceFormatter(bollData.mb)}  ',
          style: bollTextStyle.copyWith(color: colors.bollMb),
        ),
        TextSpan(
          text: 'UP:${dataViewer.priceFormatter(bollData.up)}  ',
          style: bollTextStyle.copyWith(color: colors.bollUp),
        ),
        TextSpan(
          text: 'LB:${dataViewer.priceFormatter(bollData.dn)}  ',
          style: bollTextStyle.copyWith(color: colors.bollDn),
        ),
      ];
      spanTexts.addAll(bollSpan);
    }

    if (spanTexts.isEmpty) return;

    final textPainter = TextPainter(
      text: TextSpan(children: spanTexts),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, rect.top));
  }

  /// 繪製右方的數值說明文字
  @override
  void paintRightValueText(Canvas canvas, Rect rect) {
    final chartUiStyle = dataViewer.chartUiStyle;
    final topPadding = sizes.topPadding;
    final bottomPadding = sizes.bottomPadding;
    final contentHeight = rect.height - topPadding - bottomPadding;
    final gridRows = chartUiStyle.sizeSetting.getRealRows(contentHeight);
    final rowHeight = contentHeight / gridRows;
    final rectTop = rect.top;

    final textStyle = TextStyle(
      fontSize: sizes.rightValueText,
      color: colors.rightValueText,
    );

    for (var i = 0; i <= gridRows; ++i) {
      final positionY = i * rowHeight + topPadding;

      // 取得分隔線對應的數值
      final value = realYToValue(positionY);
      final span = TextSpan(
        text: dataViewer.priceFormatter(value),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // 將數值繪製在分隔線上方
      final textY = positionY - textPainter.height;
      textPainter.paint(
        canvas,
        Offset(rect.width - textPainter.width, textY + rectTop),
      );
    }
  }

  /// 繪製圖表
  @override
  void paintChart(Canvas canvas, Rect rect) {
    // 蠟燭線跟折線只能存在一個
    if (isShowKLine) {
      paintCandleChart(canvas, rect);

      // 繪製ma線
      if (isShowMa) {
        paintMaChart(canvas, rect);
      }

      // 繪製boll線
      if (isShowBoll) {
        paintBollChart(canvas, rect);
      }
    } else if (isShowLineIndex) {
      // 折線狀態不可再有ma以及boll
      paintLineChart(canvas, rect);
    }
  }

  /// 繪製實時線
  @override
  void paintRealTimeLine(Canvas canvas, Rect rect) {
    // 取得最新一筆資料的中間x軸位置
    final dataX = dataViewer.dataIndexToRealX(dataViewer.datas.length - 1);

    // 最新一筆的資料是否仍在顯示中
    bool isNewerDisplay =
        dataViewer.endDataIndex == dataViewer.datas.length - 1;

    // 取得右側可以用來顯示的剩餘空間
    double rightRemainingSpace = dataViewer.chartUiStyle.sizeSetting.rightSpace;

    // 折線圖需要考慮到中間的寬度
    if (isShowLineIndex) {
      final dataRemainSpace = rect.width - dataX;
      if (dataRemainSpace > rightRemainingSpace) {
        rightRemainingSpace = dataRemainSpace;
      } else if (dataRemainSpace < rightRemainingSpace) {
        // 折線圖因為只有中間一點
        // 所以當dataRemainSpace < rightRemainingSpace代表最新一筆資料已經不可見
        isNewerDisplay = false;
      }
    }
    // if (isShowLineIndex) {
    //   // 折線圖
    //   rightRemainingSpace = rect.width - dataX;
    // } else {
    //   // 蠟燭圖, 需要再加上一半的蠟燭寬度
    //   rightRemainingSpace = rect.width - (dataX + (dataWidthScaled / 2));
    // }

    // if (rightRemainingSpace <= 0) {
    //   rightRemainingSpace = 0;
    // }

    pricePositionGetter?.call(
      rightRemainingSpace,
      isNewerDisplay,
      valueToRealYWithClamp,
    );
  }

  double valueToRealYWithClamp(double value) {
    var y = valueToRealY(value);
    y = y.clamp(minY, maxY);
    return y;
  }

  /// 繪製最大最小值
  @override
  void paintMaxMinValue(Canvas canvas, Rect rect) {
    if (isShowLineIndex) {
      // 圖表狀態為折線圖時不需顯示
      return;
    } else if (isMinMaxValueEqual) {
      // 最大最小值相同時不需顯示
      return;
    }

    // 圖表最大最小值一樣時不需顯示

    // 畫值
    // [value] - 需要畫的值
    // [dataIndex] - 需要畫的值對應的資料index
    // [y] - 需要畫得值對應的y軸位置
    // [textStyle] - 繪製的文字style
    void paintValue({
      required double value,
      required int dataIndex,
      required double y,
      required TextStyle textStyle,
    }) {
      // 取得資料位於畫布上的x軸位置
      final valueX = dataViewer.dataIndexToRealX(dataIndex);

      // 是否處於畫布左半邊
      final valueAtLeft = valueX < rect.width / 2;

      final valueText = valueAtLeft
          ? '── ${dataViewer.priceFormatter(value)}'
          : '${dataViewer.priceFormatter(value)} ──';

      final valuePainter = TextPainter(
        text: TextSpan(text: valueText, style: textStyle),
        textDirection: TextDirection.ltr,
      );

      valuePainter.layout();

      final valueOffsetX = valueAtLeft ? valueX : valueX - valuePainter.width;
      valuePainter.paint(
        canvas,
        Offset(valueOffsetX, y - valuePainter.height / 2),
      );
    }

    // 畫最小值
    paintValue(
      value: minValue,
      dataIndex: minValueDataIndex,
      y: maxY,
      textStyle: TextStyle(
        fontSize: sizes.minValueText,
        color: colors.minValueText,
      ),
    );

    // 畫最大值
    paintValue(
      value: maxValue,
      dataIndex: maxValueDataIndex,
      y: minY,
      textStyle: TextStyle(
        fontSize: sizes.maxValueText,
        color: colors.maxValueText,
      ),
    );
  }

  /// 繪製長按橫線與數值
  @override
  void paintLongPressHorizontalLineAndValue(Canvas canvas, Rect rect) {
    var longPressY = dataViewer.longPressY;
    final dataIndex = dataViewer.longPressDataIndex;
    if (longPressY == null || dataIndex == null) {
      return;
    }
    longPressY = longPressY - localPosition().dy;

    // 將y限制在最大最小值
    longPressY = longPressY.clamp(minY, maxY);

    final longPressX = dataViewer.dataIndexToRealX(dataIndex);

    // 繪製橫向與交叉點
    paintLongPressHorizontalPoint(
      canvas: canvas,
      rect: rect,
      longPressX: longPressX,
      longPressY: longPressY,
    );

    // 繪製y軸數值
    paintLongPressValue(
      canvas: canvas,
      rect: rect,
      longPressX: longPressX,
      longPressY: longPressY,
    );
  }
}
