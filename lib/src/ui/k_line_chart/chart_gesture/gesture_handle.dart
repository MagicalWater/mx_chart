import 'package:flutter/gestures.dart';

/// 需要處理的手勢
abstract class GestureHandle {
  /// === 橫向拖移手勢 ===
  void onHorizontalDragDown(DragDownDetails details);

  void onHorizontalDragUpdate(DragUpdateDetails details);

  void onHorizontalDragEnd(DragEndDetails details);

  void onHorizontalDragCancel();

  /// =================

  /// === 縮放手勢 ===
  void onScaleStart(ScaleStartDetails details);

  void onScaleUpdate(ScaleUpdateDetails details);

  void onScaleEnd(ScaleEndDetails details);

  /// =================

  /// === 長按手勢 ===
  void onLongPressStart(LongPressStartDetails details);

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details);

  void onLongPressEnd(LongPressEndDetails details);

  /// =================
}
