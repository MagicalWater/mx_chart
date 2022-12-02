import 'package:flutter/gestures.dart';

class TouchPointerMove {
  final int pointer;
  final Offset pendingDelta;

  final DeviceGestureSettings? gestureSettings;
  final PointerDeviceKind kind;

  TouchPointerMove({
    required this.pointer,
    required this.pendingDelta,
    required this.kind,
    required this.gestureSettings,
  });
}
