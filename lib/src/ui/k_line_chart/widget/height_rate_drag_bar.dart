import 'package:flutter/material.dart';

import '../../../clipper/clipper.dart';
import '../../widget/position_layout.dart';
import 'chart_painter/chart_painter.dart';

/// 高度比例拖曳bar
class HeightRatioDragBar extends StatefulWidget {
  final KLineChartUiStyle chartUiStyle;

  final bool enable;

  final Rect rect;

  /// 拖曳開始
  final void Function()? onDragStart;

  /// 拖曳距離
  final void Function(double offsetY)? onDragUpdate;

  /// bar條元件, [isLongPress]表示當前是否長案中
  final Widget Function(BuildContext context, bool isLongPress)? builder;

  const HeightRatioDragBar({
    Key? key,
    required this.builder,
    required this.rect,
    required this.chartUiStyle,
    this.enable = true,
    this.onDragStart,
    this.onDragUpdate,
  }) : super(key: key);

  @override
  State<HeightRatioDragBar> createState() => _HeightRatioDragBarState();
}

class _HeightRatioDragBarState extends State<HeightRatioDragBar> {
  bool isLongPressNow = false;

  @override
  Widget build(BuildContext context) {
    return PositionLayout(
      xRatio: 0,
      yFixed: widget.rect.center.dy,
      anchorPoint: Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: widget.enable
            ? (details) {
                isLongPressNow = true;
                setState(() {});
                widget.onDragStart?.call();
              }
            : null,
        onLongPressMoveUpdate: widget.enable
            ? (details) {
                widget.onDragUpdate?.call(details.offsetFromOrigin.dy);
              }
            : null,
        onLongPressCancel: widget.enable
            ? () {
                isLongPressNow = false;
                setState(() {});
              }
            : null,
        onLongPressEnd: widget.enable
            ? (details) {
                isLongPressNow = false;
                setState(() {});
              }
            : null,
        child: SizedBox(
          width: widget.rect.width - widget.chartUiStyle.sizeSetting.rightSpace,
          height: widget.rect.height,
          child: IgnorePointer(
            child: widget.builder?.call(context, isLongPressNow) ??
                _defaultDragBar(),
          ),
        ),
      ),
    );
  }

  Widget _defaultDragBar() {
    final colorSetting = widget.chartUiStyle.colorSetting;
    final color =
        isLongPressNow ? colorSetting.dragBarDragging : colorSetting.dragBar;
    final shadow =
        isLongPressNow ? color.withOpacity(0.4) : color.withOpacity(0.5);
    final width =
        widget.rect.width - widget.chartUiStyle.sizeSetting.rightSpace;
    final height = widget.chartUiStyle.sizeSetting.dragBarLineHeight;
    return Align(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLongPressNow
                ? _triangleUp(colorSetting.dragBarTriangle, const Size(8, 4))
                : const SizedBox.shrink(),
            transitionBuilder: (child, animation) {
              final offsetTween = Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              );
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetTween.animate(animation),
                  child: child,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              boxShadow: isLongPressNow
                  ? [
                      BoxShadow(
                        color: shadow,
                        blurRadius: 4,
                        spreadRadius: 4,
                      )
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLongPressNow
                ? _triangleDown(colorSetting.dragBarTriangle, const Size(8, 4))
                : const SizedBox.shrink(),
            transitionBuilder: (child, animation) {
              final offsetTween = Tween(
                begin: const Offset(0, -1),
                end: Offset.zero,
              );
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetTween.animate(animation),
                  child: child,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 向上箭頭
  Widget _triangleUp(Color color, Size size) {
    return ClipPath(
      clipper: PointClipper(
        points: [
          [
            const Offset(0, 1),
            const Offset(0.5, 0),
            const Offset(1, 1),
          ],
        ],
      ),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: color,
        ),
      ),
    );
  }

  /// 向下箭頭
  Widget _triangleDown(Color color, Size size) {
    return ClipPath(
      clipper: PointClipper(
        points: [
          [
            const Offset(0, 0),
            const Offset(0.5, 1),
            const Offset(1, 0),
          ],
        ],
      ),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: color,
        ),
      ),
    );
  }
}
