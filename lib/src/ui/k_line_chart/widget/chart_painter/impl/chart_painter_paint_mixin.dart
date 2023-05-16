import 'package:flutter/painting.dart';

import '../../../model/model.dart';
import '../../chart_render/chart_render.dart';
import '../../chart_render/drag_bar_render.dart';
import '../../chart_render/impl/drag_bar_background/drag_bar_background_render_impl.dart';
import '../../chart_render/impl/volume_chart/volume_chart_render_impl.dart';
import '../../chart_render/kdj_chart_render.dart';
import '../../chart_render/macd_chart_render.dart';
import '../../chart_render/main_chart_render.dart';
import '../../chart_render/rsi_chart_render.dart';
import '../../chart_render/wr_chart_render.dart';
import '../chart_painter.dart';

mixin ChartPainterPaintMixin on ChartPainter {
  /// 交叉豎線畫筆
  final _crossLinePaint = Paint()..isAntiAlias = true;

  /// 右方數值軸分隔線畫筆
  final _rightValueLinePaint = Paint()..isAntiAlias = true;

  /// 下方時間軸畫筆
  final _timelinePaint = Paint()..isAntiAlias = true;

  /// 下方長按時間軸畫筆
  final _longPressTimePaint = Paint()..isAntiAlias = true;

  MainChartRender? _mainChartRender;

  /// 繪製主圖表
  /// [pricePositionGetter] - 價格標示y軸位置獲取
  void paintMainChart({
    required Canvas canvas,
    required Rect rect,
    PricePositionGetter? pricePositionGetter,
    required Offset Function() localPosition,
  }) {
    switch (dataViewer.mainChartState) {
      case MainChartState.none:
        _mainChartRender = null;
        break;
      default:
        _mainChartRender ??= MainChartRenderImpl(
          dataViewer: dataViewer,
          localPosition: localPosition,
          pricePositionGetter: pricePositionGetter,
        );
        _mainChartRender?.paint(canvas, rect);
        break;
    }
  }

  /// 繪製拖拉高度比例bar的背景
  void paintDragBarBackground({
    required Canvas canvas,
    required Rect rect,
  }) {
    if (!rect.isEmpty) {
      final ChartRender render = DragBarBackgroundRenderImpl(
        dataViewer: dataViewer,
      );
      render.paint(canvas, rect);
    }
  }

  /// 繪製volume圖表
  void paintVolumeChart(Canvas canvas, Rect rect) {
    switch (dataViewer.volumeChartState) {
      case VolumeChartState.volume:
        final ChartRender render =
            VolumeChartRenderImpl(dataViewer: dataViewer);
        render.paint(canvas, rect);
        break;
      case VolumeChartState.none:
        break;
    }
  }

  /// 繪製技術指標圖表
  void paintIndicatorChart(Canvas canvas, Rect rect) {
    final ChartRender? render;
    switch (dataViewer.indicatorChartState) {
      case IndicatorChartState.macd:
        render = MACDChartRenderImpl(dataViewer: dataViewer);
        break;
      case IndicatorChartState.rsi:
        render = RSIChartRenderImpl(dataViewer: dataViewer);
        break;
      case IndicatorChartState.wr:
        render = WRChartRenderImpl(dataViewer: dataViewer);
        break;
      case IndicatorChartState.kdj:
        render = KDJChartRenderImpl(dataViewer: dataViewer);
        break;
      default:
        render = null;
        break;
    }
    render?.paint(canvas, rect);
  }

  /// 繪製長按交錯線
  void paintLongPressCrossLine(
    Canvas canvas,
    Rect mainChartRect,
  ) {
    // 取得長案的資料index
    final index = valueInfo.longPressDataIndex;
    if (index == null) {
      return;
    }
    final x = valueInfo.dataIndexToRealX(index);

    _crossLinePaint.color =
        dataViewer.chartUiStyle.colorSetting.longPressVerticalLine;
    _crossLinePaint.strokeWidth =
        dataViewer.chartUiStyle.sizeSetting.longPressVerticalLineWidth *
            chartGesture.scaleX;

    canvas.drawLine(
      Offset(x, 0),
      Offset(x, mainChartRect.bottom),
      _crossLinePaint,
    );

    if (!mainChartRect.isEmpty) {
      _mainChartRender?.paintLongPressHorizontalLineAndValue(
        canvas,
        mainChartRect,
      );
    }
  }

  /// 繪製長按時間
  void paintLongPressTime(Canvas canvas, Rect rect) {
    final index = valueInfo.longPressDataIndex;
    if (index == null) {
      return;
    }

    // 取得資料的中心x軸位置
    final x = valueInfo.dataIndexToRealX(index);

    final sizes = dataViewer.chartUiStyle.sizeSetting;
    final colors = dataViewer.chartUiStyle.colorSetting;

    final data = valueInfo.datas[index];
    final timePainter = TextPainter(
      text: TextSpan(
        text: dataViewer.xAxisDateTimeFormatter(data.dateTime),
        style: TextStyle(
          color: colors.longPressTime,
          fontSize: sizes.longPressTime,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    timePainter.layout();
    final timeWidth = timePainter.width;
    final timeHeight = timePainter.height;

    final horizontalPadding = sizes.longPressTimeBorderHorizontalPadding;
    final verticalPadding = sizes.longPressTimeBorderVerticalPadding;

    final totalWidth = horizontalPadding * 2 + timeWidth;
    final totalHeight = verticalPadding * 2 + timeHeight;

    // 時間框的位置Rect
    Rect timeRect;

    if (x - totalWidth / 2 <= rect.left) {
      // 時間顯示左側會超出邊界, 因此固定開頭在起始點
      timeRect = Rect.fromLTWH(
        rect.left,
        rect.top,
        totalWidth,
        totalHeight,
      );
    } else if (x + totalWidth / 2 >= rect.right) {
      // 時間顯示右側會超出邊界, 因此固定開頭在結束點
      timeRect = Rect.fromLTWH(
        rect.right - totalWidth,
        rect.top,
        totalWidth,
        totalHeight,
      );
    } else {
      // 可以正常於中間顯示
      timeRect = Rect.fromLTWH(
        x - totalWidth / 2,
        rect.top,
        totalWidth,
        totalHeight,
      );
    }

    // 繪製背景
    canvas.drawRect(
      timeRect,
      _longPressTimePaint
        ..style = PaintingStyle.fill
        ..color = colors.longPressTimeBg,
    );

    // 繪製外框
    canvas.drawRect(
      timeRect,
      _longPressTimePaint
        ..style = PaintingStyle.stroke
        ..color = colors.longPressTimeBorder,
    );

    // 繪製時間文字
    timePainter.paint(
      canvas,
      Offset(
        timeRect.center.dx - timeWidth / 2,
        timeRect.center.dy - timeHeight / 2,
      ),
    );
  }

  /// 繪製數值軸(y軸), 需要跳過時間軸
  void paintValueAxisLine(Canvas canvas, Rect valueRect) {
    final colors = dataViewer.chartUiStyle.colorSetting;
    final sizes = dataViewer.chartUiStyle.sizeSetting;
    _rightValueLinePaint.color = colors.rightValueLine;
    _rightValueLinePaint.strokeWidth = sizes.rightValueLine;

    canvas.drawLine(
      Offset(valueRect.left, valueRect.top),
      Offset(valueRect.left, valueRect.bottom),
      _rightValueLinePaint,
    );

    // // 繪製上方豎線
    // if (valueRect.top != timelineRect.top) {
    //   canvas.drawLine(
    //     Offset(valueRect.left, valueRect.top),
    //     Offset(valueRect.left, timelineRect.top),
    //     _rightValueLinePaint,
    //   );
    // }
    //
    // // 繪製下方豎線
    // if (valueRect.bottom != timelineRect.bottom) {
    //   canvas.drawLine(
    //     Offset(valueRect.left, timelineRect.bottom),
    //     Offset(valueRect.left, valueRect.bottom),
    //     _rightValueLinePaint,
    //   );
    // }
  }

  /// 繪製時間軸(x軸)
  void paintTimeAxis(Canvas canvas, Rect rect) {
    if (rect.isEmpty) {
      return;
    }
    final sizes = dataViewer.chartUiStyle.sizeSetting;
    final colors = dataViewer.chartUiStyle.colorSetting;

    // 繪製背景
    _timelinePaint.color = colors.timelineBg;
    canvas.drawRect(rect, _timelinePaint);

    // 繪製上方橫格線
    canvas.drawLine(
      Offset(0, rect.top),
      Offset(rect.right, rect.top),
      _timelinePaint
        ..color = colors.timelineTopDivider
        ..strokeWidth = sizes.timelineTopDivider,
    );

    _timelinePaint.strokeWidth = sizes.timelineBottomDivider;
    // 繪製下方橫格線
    canvas.drawLine(
      Offset(0, rect.bottom),
      Offset(rect.right, rect.bottom),
      _timelinePaint
        ..color = colors.timelineBottomDivider
        ..strokeWidth = sizes.timelineBottomDivider,
    );

    final contentWidth =
        rect.width - dataViewer.chartUiStyle.sizeSetting.rightSpace;
    final columnWidth = contentWidth / sizes.gridColumns;
    final timeTextStyle = TextStyle(
      color: colors.timelineText,
      fontSize: sizes.timelineText,
    );

    final lastGridIndex = sizes.gridColumns - 1;

    for (var i = lastGridIndex; i > 0; i--) {
      final x = columnWidth * i;

      DateTime dateTime;

      if (dataViewer.datas.isNotEmpty) {
        final dataIndex = dataViewer.realXToDataIndex(x);
        dateTime = dataViewer.datas[dataIndex].dateTime;
      } else {
        final subtractIndex = lastGridIndex - i;
        final subtractDuration = const Duration(days: 1) * subtractIndex;
        dateTime = DateTime.now().subtract(subtractDuration);
      }
      final textPainter = TextPainter(
        text: TextSpan(
          text: dataViewer.xAxisDateTimeFormatter(dateTime),
          style: timeTextStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          rect.center.dy - textPainter.height / 2,
        ),
      );
    }
  }
}
