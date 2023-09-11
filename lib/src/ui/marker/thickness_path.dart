// import 'dart:math';
//
// import 'package:flutter/material.dart';
//
// /// 允許點擊範圍的Path
// class ThicknessPath extends Path {
//   /// 線條寬度
//   final double strokeWidth;
//
//   ThicknessPath(this.strokeWidth) : _currentPoint = Offset.zero {
//     _outPath = Path()..moveTo(-strokeWidth, -strokeWidth);
//     _inPath = Path()..moveTo(strokeWidth, strokeWidth);
//   }
//
//   /// 外線Path, 內線Path
//   late Path _outPath, _inPath;
//
//   Offset _currentPoint;
//
//   @override
//   void moveTo(double x, double y) {
//     super.moveTo(x, y);
//     _currentPoint = Offset(x, y);
//   }
//
//   @override
//   void lineTo(double x, double y) {
//     Path();
//     double dx = x - _currentPoint.dx;
//     double dy = y - _currentPoint.dy;
//
//     double angle = atan2(dy, dx);
//     double halfWidth = strokeWidth / 2;
//
//     double xOffset1 = halfWidth * sin(angle + pi / 2);
//     double yOffset1 = halfWidth * cos(angle + pi / 2);
//     double xOffset2 = halfWidth * sin(angle - pi / 2);
//     double yOffset2 = halfWidth * cos(angle - pi / 2);
//
//     super.lineTo(x - xOffset1, y - yOffset1);
//     super.lineTo(x - xOffset2, y - yOffset2);
//     super.lineTo(_currentPoint.dx, _currentPoint.dy);
//
//     super.lineTo(x, y);
//
//     _currentPoint = Offset(x, y);
//   }
// }
