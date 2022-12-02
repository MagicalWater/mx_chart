import 'dart:ui';

import '../chart_painter/data_viewer.dart';
import 'chart_component_render.dart';

abstract class ChartRender implements ChartComponentRender {
  final DataViewer dataViewer;

  ChartRender({
    required this.dataViewer,
  });

  void paint(Canvas canvas, Rect rect);
}
