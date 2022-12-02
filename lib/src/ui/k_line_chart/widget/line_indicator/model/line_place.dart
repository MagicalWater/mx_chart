import 'package:flutter/material.dart';

/// 線條佔位
class LinePlace {
  double start, end;
  Decoration? decoration;
  Color? color;
  bool placeUp;

  LinePlace({
    required this.start,
    required this.end,
    this.decoration,
    this.color,
    this.placeUp = true,
  });
}