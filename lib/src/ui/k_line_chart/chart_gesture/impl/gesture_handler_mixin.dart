import 'dart:async';

import 'package:flutter/gestures.dart';

import '../chart_gesture.dart';
import '../gestures/gesture.dart';

/// 手勢處理
mixin GestureHandlerMixin on ChartGesture
    implements DragGesture, LongPressGesture, ScaleGesture {
  double get maxScrollX => drawContentInfo?.maxScrollX ?? 0;

  /// 上次手勢縮放時, x軸縮放倍數最後的數值
  double lastScaleX = 1;

  @override
  void onDragStart(DragStartDetails details) {
    if (chartScroller.isScroll) {
      chartScroller.stopScroll();
      onDrawUpdateNeed();
    }
  }

  @override
  void onDragUpdate(DragUpdateDetails details) {
    // 計算取得x滾動的位置
    scrollX = scrollX + details.delta.dx;

    // 滾動的位置不得超過界線
    scrollX = scrollX.clamp(0.0, maxScrollX);
    onDrawUpdateNeed();
  }

  @override
  void onDragEnd(DragEndDetails details) async {
    // 速度方向
    final scrollVelocity = details.velocity.pixelsPerSecond.dx;
    chartScroller.setScrollUpdatedCallback((value) {
      scrollX = value;

      // 如果maxScrollX == 0
      // 則依照加速度方向判斷
      // 是否已滑動至最右邊/最左邊
      var isScrollToRightSide = false;
      var isScrollToLeftSide = false;
      if (maxScrollX == 0) {
        if (scrollVelocity < 0) {
          isScrollToRightSide = true;
        } else {
          isScrollToLeftSide = true;
        }
      } else if (scrollX >= maxScrollX) {
        // 滑動到最左邊
        isScrollToLeftSide = true;
      } else if (scrollX <= 0) {
        // 滑動到最右邊
        isScrollToRightSide = true;
      }

      if (isScrollToLeftSide) {
        // 滑到最左邊
        scrollX = maxScrollX;
        onLoadMore?.call(false);
        chartScroller.stopScroll();
      } else if (isScrollToRightSide) {
        // 滑到最右邊
        scrollX = 0;
        onLoadMore?.call(true);
        chartScroller.stopScroll();
      }
      onDrawUpdateNeed();
    });

    final completer = Completer<bool>();

    // print('加速度: ${details.velocity.pixelsPerSecond.dx}');

    // 拖動結束後接著依照當前速度以及x軸位置進行模擬滑動
    chartScroller
        .startIntertialScroll(
      position: scrollX,
      velocity: scrollVelocity,
    )
        .whenCompleteOrCancel(() {
      completer.complete(true);
    });

    await completer.future;

    // isDrag = false;
    chartScroller.setScrollUpdatedCallback(null);
    onDrawUpdateNeed();
  }

  @override
  void onDragCancel() {}

  @override
  void onScaleStart(ScaleStartDetails details) {}

  @override
  void onScaleUpdate(ScaleUpdateDetails details) {
    final preScaleX = scaleX;
    scaleX = (lastScaleX * details.scale).clamp(0.5, 2.2);

    if (scrollX == 0 || scrollX == maxScrollX) {
      // 如果當前尚未滾動或者滾動到底, 則不需要在計算滾動比例
      onDrawUpdateNeed();
      return;
    }

    // 縮放中心點
    final scaleCenterX = details.focalPoint.dx;

    // 縮放中心點距離畫布最右邊的位置
    final rightCanvasDistance = drawContentInfo!.canvasWidth - scaleCenterX;

    // 縮放中心點的資料距離最右側資料的距離
    final rightAllDistance = rightCanvasDistance + scrollX;

    // 預計縮放之後資料中心點與最右側資料的距離
    final afterScaleRightAllDistance = rightAllDistance / preScaleX * scaleX;

    // 取得在保持與畫布右側的距離下的scrollX
    scrollX = afterScaleRightAllDistance - rightCanvasDistance;

    // scrollX + rightCanvasDistance = afterScaleRightAllDistance;

    final nextChartTotalWidth =
        drawContentInfo!.chartTotalWidth / preScaleX * scaleX;

    final nextMaxScrollX = nextChartTotalWidth - drawContentInfo!.canvasWidth;

    scrollX = scrollX.clamp(0.0, nextMaxScrollX);
    onDrawUpdateNeed();
  }

  @override
  void onScaleEnd(ScaleEndDetails details) {
    lastScaleX = scaleX;
  }

  @override
  void onScaleCancel() {
    lastScaleX = scaleX;
  }

  @override
  void onLongPressStart(LongPressStartDetails details) {
    isLongPress = true;
    if (longPressX != details.localPosition.dx ||
        longPressY != details.localPosition.dy) {
      longPressX = details.localPosition.dx;
      longPressY = details.localPosition.dy;
      onDrawUpdateNeed();
    }
  }

  @override
  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (longPressX != details.localPosition.dx ||
        longPressY != details.localPosition.dy) {
      longPressX = details.localPosition.dx;
      longPressY = details.localPosition.dy;
      onDrawUpdateNeed();
    }
  }

  @override
  void onLongPressEnd(LongPressEndDetails details) {
    longPressX = 0;
    longPressY = 0;
    onDrawUpdateNeed();
  }

  @override
  void onLongPressCancel() {
    longPressX = 0;
    longPressY = 0;
    onDrawUpdateNeed();
  }
}
