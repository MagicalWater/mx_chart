import 'dart:ui';

import 'chart_component_render.dart';
import 'chart_render.dart';

export 'impl/volume_chart/volume_chart_render_impl.dart';

abstract class VolumeChartRender extends ChartRender
    implements ChartComponentRender {
  VolumeChartRender({
    required dataViewer,
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
