import 'package:flutter/material.dart';

/// 圖表慣性滾動
class ChartInertialScroller {
  final AnimationController _controller;

  ChartInertialScroller({required AnimationController controller})
      : _controller = controller {
    _controller.addListener(() {
      _scrollUpdated?.call(_controller.value);
    });
  }

  ValueChanged? _scrollUpdated;

  /// 設置滑動更新時回調
  void setScrollUpdatedCallback(ValueChanged? callback) {
    _scrollUpdated = callback;
  }

  /// 是否正在慣性滾動中
  bool get isScroll => _controller.isAnimating;

  /// 停止滾動
  void stopScroll() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  /// 滑動到
  TickerFuture animatedScrollTo({required double from, required double to}) {
    _controller.value = from;
    return _controller.animateTo(
      to,
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  /// 進行慣性滾動
  /// [position] - 開始進行慣性滾動的位置
  /// [velocity] - 初始慣性滑動速率
  TickerFuture startIntertialScroll({
    required double position,
    required double velocity,
  }) {
    // final pixelRatio = WidgetsBinding.instance!.window.devicePixelRatio;

    // final tolerance = Tolerance(
    //   velocity: 1.0 / (0.050 * pixelRatio),
    //   distance: 1.0 / pixelRatio,
    // );

    // 從 [position] 開始進行模擬滾動
    final simulation = ClampingScrollSimulation(
      position: position,
      velocity: velocity,
      // tolerance: tolerance,
      // 滾動摩擦力, 預設為0.015
      friction: 0.003,
    );
    return _controller.animateWith(simulation);
  }

  void dispose() {
    _controller.dispose();
    _scrollUpdated = null;
  }
}
