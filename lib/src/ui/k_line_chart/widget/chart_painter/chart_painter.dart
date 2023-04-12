import 'package:flutter/material.dart';

import '../../chart_gesture/chart_gesture.dart';
import '../../model/model.dart';
import 'data_viewer.dart';

export 'split/split.dart';

abstract class ChartPainter extends CustomPainter {
  ChartPainterValueInfo get valueInfo => dataViewer.valueInfo;

  final DataViewer dataViewer;

  ChartGesture get chartGesture => valueInfo.chartGesture;

  ChartPainter({
    required this.dataViewer,
  });
}
