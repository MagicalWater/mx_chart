import 'package:flutter/material.dart';

import '../../chart_inertial_scroller/chart_inertial_scroller.dart';
import '../chart_gesture.dart';
import 'gesture_distribution_mixin.dart';
import 'gesture_handler_mixin.dart';

/// 圖表手勢處理
class ChartGestureImpl extends ChartGesture
    with GestureHandlerMixin, GestureDistributionMixin {
  ChartGestureImpl({
    required VoidCallback onDrawUpdateNeed,
    required ChartInertialScroller chartScroller,
    Function(bool right)? onLoadMore,
  }) : super(
          onDrawUpdateNeed: onDrawUpdateNeed,
          chartScroller: chartScroller,
          onLoadMore: onLoadMore,
        );
}
