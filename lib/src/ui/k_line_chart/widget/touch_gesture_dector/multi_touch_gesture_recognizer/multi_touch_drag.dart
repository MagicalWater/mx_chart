import 'dart:ui';

import 'package:flutter/gestures.dart';

class MultiTouchDrag extends Drag {
  final int pointer;
  final void Function(DragUpdateDetails details)? onUpdate;
  final void Function(DragEndDetails details)? onEnd;
  final VoidCallback? onCancel;

  MultiTouchDrag({
    required this.pointer,
    this.onUpdate,
    this.onEnd,
    this.onCancel,
  });

  @override
  void update(DragUpdateDetails details) {
    onUpdate?.call(details);
    super.update(details);
  }

  @override
  void end(DragEndDetails details) {
    onEnd?.call(details);
    super.end(details);
  }

  @override
  void cancel() {
    onCancel?.call();
    super.cancel();
  }
}
