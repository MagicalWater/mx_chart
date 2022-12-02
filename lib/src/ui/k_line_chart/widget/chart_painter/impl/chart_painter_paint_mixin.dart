import 'package:flutter/painting.dart';

import '../../../model/model.dart';
import '../../chart_render/chart_render.dart';
import '../../chart_render/impl/main_chart/main_chart_render_impl.dart';
import '../../chart_render/impl/volume_chart/volume_chart_render_impl.dart';
import '../../chart_render/kdj_chart_render.dart';
import '../../chart_render/macd_chart_render.dart';
import '../../chart_render/main_chart_render.dart';
import '../../chart_render/rsi_chart_render.dart';
import '../../chart_render/scroll_bar_render.dart';
import '../../chart_render/wr_chart_render.dart';
import '../chart_painter.dart';

mixin ChartPainterPaintMixin on ChartPainter {
  /// 交叉豎線畫筆
  final _crossLinePaint = Paint()..isAntiAlias = true;

  /// 右方數值軸分隔線畫筆
  final _rightValueLinePaint = Paint()..isAntiAlias = true;

  /// 下方時間軸畫筆
  final _bottomTimePaint = Paint()..isAntiAlias = true;

  /// 下方長按時間軸畫筆
  final _longPressTimePaint = Paint()..isAntiAlias = true;

  MainChartRender? _mainChartRender;

  /// 繪製主圖表
  /// [pricePositionGetter] - 價格標示y軸位置獲取
  void paintMainChart({
    required Canvas canvas,
    required Rect rect,
    PricePositionGetter? pricePositionGetter,
  }) {
    _mainChartRender ??= MainChartRenderImpl(
      dataViewer: this,
      pricePositionGetter: pricePositionGetter,
    );
    _mainChartRender?.paint(canvas, rect);
  }

  /// 繪製拖拉高度比例bar的背景
  void paintScrollBarBackground({
    required Canvas canvas,
    required Rect rect,
  }) {
    final ChartRender render = ScrollBarBackgroundRenderImpl(
      dataViewer: this,
    );
    render.paint(canvas, rect);
  }

  /// 繪製volume圖表
  void paintVolumeChart(Canvas canvas, Rect rect) {
    switch (volumeChartState) {
      case VolumeChartState.volume:
        final ChartRender render = VolumeChartRenderImpl(dataViewer: this);
        render.paint(canvas, rect);
        break;
      case VolumeChartState.none:
        break;
    }
  }

  /// 繪製技術指標圖表
  void paintIndicatorChart(Canvas canvas, Rect rect) {
    final ChartRender? render;
    switch (indicatorChartState) {
      case IndicatorChartState.macd:
        render = MACDChartRenderImpl(dataViewer: this);
        break;
      case IndicatorChartState.rsi:
        render = RSIChartRenderImpl(dataViewer: this);
        break;
      case IndicatorChartState.wr:
        render = WRChartRenderImpl(dataViewer: this);
        break;
      case IndicatorChartState.kdj:
        render = KDJChartRenderImpl(dataViewer: this);
        break;
      default:
        render = null;
        break;
    }
    render?.paint(canvas, rect);
  }

  /// 繪製長按交錯線
  void paintLongPressCrossLine(Canvas canvas, Size size, Rect mainChartRect) {
    // 取得長案的資料index
    final index = getLongPressDataIndex();
    if (index == null) {
      return;
    }
    final x = dataIndexToRealX(index);
    _crossLinePaint.color = chartUiStyle.colorSetting.longPressVerticalLine;
    _crossLinePaint.strokeWidth =
        chartUiStyle.sizeSetting.longPressVerticalLineWidth *
            chartGesture.scaleX;

    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height - chartUiStyle.heightRatioSetting.bottomTimeFixed),
      _crossLinePaint,
    );

    _mainChartRender?.paintLongPressHorizontalLineAndValue(canvas, mainChartRect);
  }

  /// 繪製長按時間
  void paintLongPressTime(Canvas canvas, Rect rect) {
    final index = getLongPressDataIndex();
    if (index == null) {
      return;
    }

    // 取得資料的中心x軸位置
    final x = dataIndexToRealX(index);

    final sizes = chartUiStyle.sizeSetting;
    final colors = chartUiStyle.colorSetting;

    final data = datas[index];
    final timePainter = TextPainter(
      text: TextSpan(
        text: xAxisDateTimeFormatter(data.dateTime),
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

  /// 繪製數值軸(y軸)
  void paintValueAxisLine(Canvas canvas, Rect rect) {
    final colors = chartUiStyle.colorSetting;
    final sizes = chartUiStyle.sizeSetting;
    _rightValueLinePaint.color = colors.rightValueLine;
    _rightValueLinePaint.strokeWidth = sizes.rightValueLine;

    // 繪製上方橫格線
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.bottom),
      _rightValueLinePaint,
    );
  }

  /// 繪製時間軸(x軸)
  void paintTimeAxis(Canvas canvas, Rect rect) {
    final sizes = chartUiStyle.sizeSetting;
    final colors = chartUiStyle.colorSetting;

    // 繪製背景
    _bottomTimePaint.color = colors.bottomTimeBg;
    canvas.drawRect(rect, _bottomTimePaint);

    // 繪製上方橫格線
    canvas.drawLine(
      Offset(0, rect.top),
      Offset(rect.right, rect.top),
      _bottomTimePaint..color = colors.grid,
    );

    final contentWidth = rect.width - chartUiStyle.sizeSetting.rightSpace;
    final columnWidth = contentWidth / sizes.gridColumns;
    final timeTextStyle = TextStyle(
      color: colors.bottomTimeText,
      fontSize: sizes.bottomTimeText,
    );

    final lastGridIndex = sizes.gridColumns - 1;

    for (var i = lastGridIndex; i > 0; i--) {
      final x = columnWidth * i;

      DateTime dateTime;

      if (datas.isNotEmpty) {
        final dataIndex = realXToDataIndex(x);
        dateTime = datas[dataIndex].dateTime;
      } else {
        final subtractIndex = lastGridIndex - i;
        final subtractDuration = const Duration(days: 1) * subtractIndex;
        dateTime = DateTime.now().subtract(subtractDuration);
      }
      final textPainter = TextPainter(
        text: TextSpan(
          text: xAxisDateTimeFormatter(dateTime),
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
