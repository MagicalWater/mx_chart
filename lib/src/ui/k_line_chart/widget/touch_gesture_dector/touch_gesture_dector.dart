import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'multi_touch_gesture_recognizer/multi_touch_gesture_recognizer.dart';

export 'package:flutter/gestures.dart';
export 'multi_touch_gesture_recognizer/multi_touch_gesture_recognizer.dart';

class TouchGestureDetector extends StatefulWidget {
  final void Function(int pointer, DragStartDetails details)? onTouchStart;
  final void Function(int pointer, DragUpdateDetails details)? onTouchUpdate;
  final void Function(int pointer, DragEndDetails details)? onTouchEnd;
  final void Function(int pointer)? onTouchCancel;

  /// 當前點擊狀態(影響到決策點擊是否引入)
  final GestureDisposition? Function(TouchPointerMove move)? isAllowPointerMove;

  final Widget? child;

  /// 觸摸檢測行為
  final HitTestBehavior? behavior;

  const TouchGestureDetector({
    Key? key,
    this.child,
    this.onTouchStart,
    this.onTouchUpdate,
    this.onTouchEnd,
    this.onTouchCancel,
    this.isAllowPointerMove,
    this.behavior,
  }) : super(key: key);

  @override
  State<TouchGestureDetector> createState() => _TouchGestureDetectorState();
}

class _TouchGestureDetectorState extends State<TouchGestureDetector> {
  /// 手勢觸摸元件的GlobalKey
  /// 用於供給[MultiTouchGestureRecognizer]可進行localPostion的更新
  final GlobalKey<RawGestureDetectorState> gestureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      key: gestureKey,
      behavior: widget.behavior,
      gestures: <Type, GestureRecognizerFactory>{
        MultiTouchGestureRecognizer: MultiTouchGestureRecognizer.factory(
          transformPositionKey: gestureKey,
          onTouchStart: widget.onTouchStart,
          onTouchUpdate: widget.onTouchUpdate,
          onTouchEnd: widget.onTouchEnd,
          onTouchCancel: widget.onTouchCancel,
          isAllowPointerMove: widget.isAllowPointerMove,
        ),
      },
      child: widget.child,
    );
  }
}
