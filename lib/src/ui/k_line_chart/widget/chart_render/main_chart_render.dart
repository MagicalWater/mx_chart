import 'dart:ui';

import '../../k_line_chart.dart';
import '../chart_painter/data_viewer.dart';
import 'chart_component_render.dart';
import 'chart_render.dart';

export 'impl/main_chart/main_chart_render_impl.dart';

abstract class MainChartRender extends ChartRender
    implements ChartComponentRender {
  /// 價格標示y軸位置獲取
  final ChartPositionGetter? pricePositionGetter;

  /// 在父元件的偏移位置
  final Offset Function() localPosition;

  MainChartRender({
    required DataViewer dataViewer,
    required this.localPosition,
    this.pricePositionGetter,
  }) : super(dataViewer: dataViewer);

  @override
  void paint(Canvas canvas, Rect rect) {
    final sizes = dataViewer.mainChartUiStyle.sizeSetting;
    initValue(rect);
    paintBackground(canvas, rect);
    paintGrid(canvas, rect);
    paintDivider(canvas, rect);
    // 可以繪製圖表資料的區塊
    final chartRect = Rect.fromLTRB(
      rect.left,
      rect.top + sizes.topPadding,
      rect.right - dataViewer.chartUiStyle.sizeSetting.rightSpace,
      rect.bottom - sizes.bottomPadding,
    );
    canvas.save();
    canvas.clipRect(chartRect);
    paintChart(canvas, rect);
    canvas.restore();
    paintRightValueText(canvas, rect);
    if (dataViewer.datas.isEmpty) {
      return;
    }
    paintTopValueText(canvas, rect);
    // 可以繪製最大最小值的區塊
    final mixVaxValueRect = Rect.fromLTRB(
      rect.left,
      rect.top,
      rect.right - dataViewer.chartUiStyle.sizeSetting.rightSpace,
      rect.bottom,
    );
    canvas.save();
    canvas.clipRect(mixVaxValueRect);
    paintMaxMinValue(canvas, rect);
    canvas.restore();
    paintRealTimeLine(canvas, rect);
  }

  /// 繪製實時線
  void paintRealTimeLine(Canvas canvas, Rect rect);

  /// 繪製最大值與最小值
  void paintMaxMinValue(Canvas canvas, Rect rect);

  /// 繪製長按橫線與數值
  void paintLongPressHorizontalLineAndValue(Canvas canvas, Rect rect);
}
