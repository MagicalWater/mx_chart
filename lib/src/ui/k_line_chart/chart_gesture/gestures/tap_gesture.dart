import 'package:flutter/gestures.dart';

/// 需要處理的手勢
abstract class TapGesture {
  void onTouchDown(int pointer, DragStartDetails details);

  void onTouchUpdate(int pointer, DragUpdateDetails details);

  void onTouchUp(int pointer, DragEndDetails details);

  /// 取消觸摸(當觸摸後沒有任何位移, 則會呼叫此)
  void onTouchCancel(int pointer);
}
