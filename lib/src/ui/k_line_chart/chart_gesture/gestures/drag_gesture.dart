import 'package:flutter/gestures.dart';

abstract class DragGesture {
  void onDragStart(DragStartDetails details);
  void onDragUpdate(DragUpdateDetails details);
  void onDragEnd(DragEndDetails details);
  void onDragCancel();
}