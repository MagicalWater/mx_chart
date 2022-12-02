import 'dart:ui';

import '../chart_painter/data_viewer.dart';
import 'chart_component_render.dart';
import 'chart_render.dart';

export 'impl/scroll_bar_background/scroll_bar_background_render_impl.dart';

/// 拖拉bar的背景渲染
abstract class ScrollBarBackgroundRender extends ChartRender
    implements ChartComponentRender {
  ScrollBarBackgroundRender({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  @override
  void paint(Canvas canvas, Rect rect) {
    paintBackground(canvas, rect);
    paintGrid(canvas, rect);
  }
}
