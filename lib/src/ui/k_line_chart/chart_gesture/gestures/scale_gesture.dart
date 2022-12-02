import 'package:flutter/gestures.dart';

abstract class ScaleGesture {
  void onScaleStart(ScaleStartDetails details);
  void onScaleUpdate(ScaleUpdateDetails details);
  void onScaleEnd(ScaleEndDetails details);
  void onScaleCancel();
}