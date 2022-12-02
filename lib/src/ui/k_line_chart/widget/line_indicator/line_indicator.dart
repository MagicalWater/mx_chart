import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_chart/src/util/num_util/num_util.dart';

import 'model/model.dart';
export 'model/model.dart';

part 'line_painter.dart';

class _PlacePainter {
  Decoration decoration;
  BoxPainter painter;
  double start, end;
  bool placeUp;

  _PlacePainter({
    required this.decoration,
    required this.painter,
    required this.start,
    required this.end,
    required this.placeUp,
  });
}

/// 線條指示器, 如同 TabBar 底下的 Indicator
/// 但有時會單獨需要此類功能, 因此獨立製作
class LineIndicator extends StatefulWidget {
  /// 方向
  final Axis direction;

  /// 線的粗細, 沒帶入則占滿
  final double? size;

  /// 線最大長度
  /// 依照 [direction] 不同所指不同
  /// [Axis.horizontal] => 線條最大寬度
  /// [Axis.vertical] => 線條最大高度
  final double? maxLength;

  /// 線的邊距
  /// 依照 [direction] 不同所指不同
  /// [Axis.horizontal] => 線條橫向邊距
  /// [Axis.vertical] => 線條最大高度
  final EdgeInsets? padding;

  /// 此參數優先於 color
  final Decoration? decoration;

  /// 若線條空間沒填滿
  /// 則需要設置對齊位置
  final Alignment alignment;

  /// 線條顏色
  final Color? color;

  /// 線條開始百分比位置, 0 < value < 1
  final double start;

  /// 線條結尾百分比位置, 0 < value < 1
  final double end;

  /// 插值器
  final Curve curve;

  /// 動畫時間
  final Duration duration;

  /// 從無至有顯示是否使用動畫
  final bool appearAnimation;

  /// 是否啟用動畫
  final bool animation;

  /// 線條佔位
  final List<LinePlace>? places;

  /// 虛線風格
  final DashStyle? dashStyle;

  const LineIndicator({
    Key? key,
    required this.start,
    required this.end,
    this.color,
    this.decoration,
    this.direction = Axis.horizontal,
    this.alignment = Alignment.center,
    this.size,
    this.maxLength,
    this.padding,
    this.curve = Curves.easeInOutSine,
    this.duration = const Duration(milliseconds: 300),
    this.places,
    this.dashStyle,
    this.appearAnimation = true,
    this.animation = true,
  })  : assert(color != null || decoration != null),
        super(key: key);

  @override
  State<LineIndicator> createState() => _LineIndicatorState();
}

class _LineIndicatorState extends State<LineIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Tween<double>? startTween;
  Tween<double>? endTween;
  Tween<Decoration>? decorationTween;

  Animation<double>? startAnim;
  Animation<double>? endAnim;
  Animation<Decoration>? decorationAnim;

  bool startAnimEnable = false,
      endAnimEnable = false,
      decorationAnimEnable = false;

  double currentStart = 0;
  double currentEnd = 0;
  Decoration currentDecoration = const BoxDecoration();

  BoxPainter? painter;

  List<_PlacePainter> placePainter = [];

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    syncShow(widget);
    _controller.addListener(_handleAnimValueUpdate);
    super.initState();
  }

  void _handleAnimValueUpdate() {
    if (startAnimEnable && startAnim != null) {
      currentStart = startAnim!.value;
    }
    if (endAnimEnable && endAnim != null) {
      currentEnd = endAnim!.value;
    }
    if (decorationAnimEnable && decorationAnim != null) {
      currentDecoration = decorationAnim!.value;
      painter?.dispose();
      painter = currentDecoration.createBoxPainter(() => setState(() {}));
    }
    setState(() {});
  }

  void releaseAllPlacePainter() {
    for (var element in placePainter) {
      element.painter.dispose();
    }
    placePainter.clear();
  }

  @override
  void didUpdateWidget(LineIndicator oldWidget) {
    _controller.duration = widget.duration;
    syncShow(widget);
    super.didUpdateWidget(oldWidget);
  }

  void syncShow(LineIndicator widget) {
    // 同步 widget.places 與 placePainter 的數量
    void syncPlacePainter() {
      var places = widget.places ?? [];
      if (places.isEmpty) {
        releaseAllPlacePainter();
        return;
      }

      for (var i = 0; i < places.length; i++) {
        var newPlace = widget.places![i];
        var placeDecoration =
            newPlace.decoration ?? BoxDecoration(color: newPlace.color);
        if (placePainter.length > i) {
          var painterPair = placePainter[i];
          if (painterPair.decoration != placeDecoration) {
            painterPair.painter.dispose();
            painterPair.decoration = placeDecoration;
            painterPair.painter = painterPair.decoration.createBoxPainter(() {
              setState(() {});
            });
          }

          painterPair.start = newPlace.start;
          painterPair.end = newPlace.end;
          painterPair.placeUp = newPlace.placeUp;
        } else {
          var painter = _PlacePainter(
            decoration: placeDecoration,
            painter: placeDecoration.createBoxPainter(() {
              setState(() {});
            }),
            start: newPlace.start,
            end: newPlace.end,
            placeUp: newPlace.placeUp,
          );
          placePainter.add(painter);
        }
      }

      if (placePainter.length > places.length) {
        placePainter.removeLast().painter.dispose();
      }
    }

    syncPlacePainter();

    startAnimEnable = false;
    endAnimEnable = false;
    decorationAnimEnable = false;

    final newDecoration =
        widget.decoration ?? BoxDecoration(color: widget.color);

    final isDecorationDifference = currentDecoration != newDecoration;

    if (isDecorationDifference) {
      painter?.dispose();
      painter = null;
    }

    if (!widget.appearAnimation) {
      final isStartAppear = currentStart == 0 || (currentStart == currentEnd);
      final isEndAppear = currentEnd == 0 || (currentStart == currentEnd);

      if (isStartAppear && isEndAppear) {
        currentStart = widget.start;
        currentEnd = widget.end;
        currentDecoration = newDecoration;
        painter ??= currentDecoration.createBoxPainter(() => setState(() {}));
        return;
      }
    }

    if (!widget.animation) {
      currentStart = widget.start;
      currentEnd = widget.end;
      currentDecoration = newDecoration;
      painter ??= currentDecoration.createBoxPainter(() => setState(() {}));
      return;
    }

    if (isDecorationDifference) {
      decorationAnimEnable = true;
      if (decorationTween != null) {
        decorationTween!.begin = currentDecoration;
        decorationTween!.end = newDecoration;
      } else {
        decorationTween = DecorationTween(
          begin: currentDecoration,
          end: newDecoration,
        );
        decorationAnim = decorationTween!.animate(CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ));
      }
    }

    painter ??= currentDecoration.createBoxPainter(() => setState(() {}));

    if (currentStart != widget.start) {
      startAnimEnable = true;
      if (startTween != null) {
        startTween!.begin = currentStart;
        startTween!.end = widget.start;
      } else {
        double startPoint;
        if (currentStart == 0 && currentEnd == 0) {
          startPoint = (widget.start + widget.end) / 2;
        } else {
          startPoint = currentStart;
        }
        startTween = Tween(begin: startPoint, end: widget.start);
        startAnim = startTween!.animate(CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ));
      }
    }

    if (currentEnd != widget.end) {
      endAnimEnable = true;
      if (endTween != null) {
        endTween!.begin = currentEnd;
        endTween!.end = widget.end;
      } else {
        double endPoint;
        if (currentStart == 0 && currentEnd == 0) {
          endPoint = (widget.start + widget.end) / 2;
        } else {
          endPoint = currentEnd;
        }
        endTween = Tween(begin: endPoint, end: widget.end);
        endAnim = endTween!.animate(CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ));
      }
    }

    if (startAnimEnable || endAnimEnable || decorationAnimEnable) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.direction == Axis.vertical ? widget.size : null,
      height: widget.direction == Axis.horizontal ? widget.size : null,
      child: CustomPaint(
        painter: _LinePainter(
          start: currentStart,
          end: currentEnd,
          lineSize: widget.size,
          maxLength: widget.maxLength,
          padding: widget.padding ?? EdgeInsets.zero,
          direction: widget.direction,
          alignment: widget.alignment,
          painter: painter!,
          placePainters: placePainter,
          dashStyle: widget.dashStyle,
        ),
        child: Container(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleAnimValueUpdate);
    _controller.dispose();

    painter?.dispose();

    releaseAllPlacePainter();

    super.dispose();
  }
}