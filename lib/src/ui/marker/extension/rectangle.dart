import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/chart_marker_painter.dart';

/// 矩形
extension RectangleMarker on ChartMarkerPainter {
  /// 矩形
  Path? drawRectangle(Canvas canvas, Size size, MarkerData data) {
    // 取得兩個點
    final point1 = data.positions[0];
    final point2 = data.positions[1];

    // 取得這兩個點的座標位置
    final x1 = painterValueInfo.timeToDisplayX(
          point1.dateTime,
          percent: point1.xRate,
        ) ??
        painterValueInfo.estimateTimeToDisplayX(
          point1.dateTime,
          period: period,
          percent: point1.xRate,
        );

    final x2 = painterValueInfo.timeToDisplayX(
          point2.dateTime,
          percent: point2.xRate,
        ) ??
        painterValueInfo.estimateTimeToDisplayX(
          point2.dateTime,
          period: period,
          percent: point2.xRate,
        );

    // 只要有一個點是null, 就不繪製
    if (x1 == null || x2 == null) {
      return null;
    }

    // 取得真實的x軸位置
    final realX1 = painterValueInfo.displayXToRealX(x1);
    final realX2 = painterValueInfo.displayXToRealX(x2);

    // 轉化為真實的y軸位置
    final realY1 = pricePosition.priceToY(point1.price);
    final realY2 = pricePosition.priceToY(point2.price);

    // 生成需要繪製的路徑
    final path = Path()
      ..moveTo(realX1, realY1)
      ..lineTo(realX2, realY1)
      ..lineTo(realX2, realY2)
      ..lineTo(realX1, realY2)
      ..close();

    // 生成繪製畫筆
    final paint = Paint()
      ..color = data.color.withOpacity(0.5)
      ..strokeWidth = data.strokeWidth
      ..style = PaintingStyle.fill;

    // 先畫背景
    canvas.drawPath(path, paint);

    // 畫路徑
    paint
      ..color = data.color
      ..strokeWidth = data.strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    return path;
  }
}
