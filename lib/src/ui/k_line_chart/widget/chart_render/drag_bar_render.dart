import 'dart:ui';

import '../chart_painter/data_viewer.dart';
import 'chart_component_render.dart';
import 'chart_render.dart';

export 'impl/drag_bar_background/drag_bar_background_render_impl.dart';

/// 拖拉bar的背景渲染
abstract class DragBarBackgroundRender extends ChartRender
    implements ChartComponentRender {
  DragBarBackgroundRender({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paint(Canvas canvas, Rect rect) {
    paintBackground(canvas, rect);
    paintGrid(canvas, rect);
  }
}
