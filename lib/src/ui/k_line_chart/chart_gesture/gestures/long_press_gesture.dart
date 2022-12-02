import 'package:flutter/gestures.dart';

abstract class LongPressGesture {
  void onLongPressStart(LongPressStartDetails details);
  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details);
  void onLongPressEnd(LongPressEndDetails details);
  void onLongPressCancel();
}