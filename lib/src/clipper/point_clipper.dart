import 'package:flutter/material.dart';

/// 設置多個點的路徑剪裁
class PointClipper extends CustomClipper<Path> {
  final List<List<Offset>> Function(Size size) pointBuilder;

  const PointClipper.builder({
    required this.pointBuilder,
  });

  factory PointClipper({
    required List<List<Offset>> points,
    bool fixed = false,
  }) {
    return PointClipper.builder(pointBuilder: (size) {
      return points.map((pointGroup) {
        return pointGroup.map((e) {
          var x = e.dx, y = e.dy;
          final maxW = size.width, maxH = size.height;

          if (x <= 0) {
            x = 0;
          }
          if (y <= 0) {
            y = 0;
          }

          if (fixed) {
            if (x >= maxW) {
              x = maxW;
            }
            if (y >= maxH) {
              y = maxH;
            }
          } else {
            if (x >= 1) {
              x = maxW;
            } else {
              x = maxW * x;
            }

            if (y >= 1) {
              y = maxH;
            } else {
              y = maxH * y;
            }
          }

          return Offset(x, y);
        }).toList();
      }).toList();
    });
  }

  @override
  Path getClip(Size size) {
    final path = Path();
    for (var pointGroup in pointBuilder(size)) {
      var firstMove = true;
      for (var element in pointGroup) {
        if (firstMove) {
          path.moveTo(element.dx, element.dy);
          firstMove = false;
        } else {
          path.lineTo(element.dx, element.dy);
        }
      }
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
