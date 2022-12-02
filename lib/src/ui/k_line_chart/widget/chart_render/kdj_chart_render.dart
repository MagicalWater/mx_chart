import 'dart:ui';

import '../chart_painter/data_viewer.dart';
import 'chart_component_render.dart';
import 'chart_render.dart';

export 'impl/kdj_chart/kdj_chart_render_impl.dart';

abstract class KDJChartRender extends ChartRender
    implements ChartComponentRender {
  KDJChartRender({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paint(Canvas canvas, Rect rect) {
    initValue(rect);
    paintBackground(canvas, rect);
    paintGrid(canvas, rect);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(
      rect.left,
      rect.top,
      rect.right - dataViewer.chartUiStyle.sizeSetting.rightSpace,
      rect.bottom,
    ));
    paintChart(canvas, rect);
    canvas.restore();
    paintRightValueText(canvas, rect);
    if (dataViewer.datas.isEmpty) {
      return;
    }
    paintTopValueText(canvas, rect);
  }
}
