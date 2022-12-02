import 'package:flutter/material.dart';

import '../../chart_gesture/chart_gesture.dart';
import '../../model/model.dart';
import 'data_viewer.dart';

export 'impl/chart_painter_impl.dart';

abstract class ChartPainter extends CustomPainter implements DataViewer {
  final ChartGesture chartGesture;

  /// 當取得最大滾動距離時回調
  final ValueChanged<DrawContentInfo>? onDrawInfo;

  /// 當取得長按對應的資料時回調
  final ValueChanged<LongPressData?>? onLongPressData;

  ChartPainter({
    required this.chartGesture,
    required this.onDrawInfo,
    required this.onLongPressData,
  });
}
