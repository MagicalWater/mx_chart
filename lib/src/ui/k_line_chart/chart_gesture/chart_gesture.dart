import 'dart:async';

import 'package:flutter/material.dart';

import '../chart_inertial_scroller/chart_inertial_scroller.dart';
import '../model/model.dart';
import 'gestures/tap_gesture.dart';

/// 手勢狀態
enum TouchStatus {
  none,
  drag,
  scale,
  longPress,
}

/// 圖表手勢處理
abstract class ChartGesture implements TapGesture {
  /// 是否正在縮放 / 拖移 / 長按
  bool isScale = false, isDrag = false, isLongPress = false;

  /// x軸滾動的距離
  double scrollX = 0;

  /// x軸縮放倍數
  double scaleX = 1;

  /// x軸被長按的位置
  double longPressX = 0, longPressY = 0;

  /// 元件繪製完成後才可獲取到的資料
  /// 1. x軸可滑動距離, 2. 資料表總寬度, 3. 畫布寬度
  DrawContentInfo? drawContentInfo;

  /// 慣性滑動
  final ChartInertialScroller chartScroller;

  /// 需要繪製的屬性變更
  /// 代表需要通知外部進行畫面刷新
  final VoidCallback onDrawUpdateNeed;

  /// 滑動到最左/最右回調
  final Function(bool right)? onLoadMore;

  ChartGesture({
    required this.onDrawUpdateNeed,
    required this.chartScroller,
    this.onLoadMore,
  });

  /// 設置最大可滾動距離
  void setDrawInfo(DrawContentInfo info) {
    drawContentInfo = info;
  }

  /// 取得某個pointer的狀態
  TouchStatus getTouchPointerStatus(int pointer);

  /// 滑動到scrollX為0的位置
  /// [animated] - 是否動畫滾動
  Future<void> scrollToRight({bool animated = true}) async {
    if (animated) {
      chartScroller.setScrollUpdatedCallback((value) {
        scrollX = value;
        if (scrollX <= 0) {
          // 滑到最右邊
          scrollX = 0;
          onLoadMore?.call(true);
          chartScroller.stopScroll();
        }
        onDrawUpdateNeed();
      });

      final completer = Completer<bool>();

      // 拖動結束後接著依照當前速度以及x軸位置進行模擬滑動
      chartScroller
          .animatedScrollTo(from: scrollX, to: 0)
          .whenCompleteOrCancel(() {
        completer.complete(true);
      });

      await completer.future;

      // isDrag = false;
      chartScroller.setScrollUpdatedCallback(null);
      onDrawUpdateNeed();
    } else {
      scrollX = 0;
      onDrawUpdateNeed();
    }
  }

  void dispose() {
    chartScroller.dispose();
  }
}
