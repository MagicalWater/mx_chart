import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/chart_marker_painter.dart';

/// 垂直延伸
extension VerticalExtendMarker on ChartMarkerPainter {
  /// 垂直延伸
  Path? drawVerticalExtend(Canvas canvas, Size size, MarkerData data) {
    // 取得兩個點
    final point1 = data.positions[0];
    final point2 = data.positions[1];

    // x將以第一個點為主
    final x1 = painterValueInfo.timeToDisplayX(
          point1.dateTime,
          percent: point1.xRate,
        ) ??
        painterValueInfo.estimateTimeToDisplayX(
          point1.dateTime,
          period: period,
          percent: point1.xRate,
        );

    // 點是null, 就不繪製
    if (x1 == null) {
      return null;
    }

    // 取得真實的x軸位置
    final realStartX = painterValueInfo.displayXToRealX(x1);

    final realStartY = pricePosition.priceToY(point1.price);
    final realEndY = pricePosition.priceToY(point2.price);

    // 生成需要繪製的路徑
    final path = Path()
      ..moveTo(realStartX, realStartY)
      ..lineTo(realStartX, realEndY);

    // 生成繪製畫筆
    final paint = Paint()
      ..color = data.color
      ..strokeWidth = data.strokeWidth
      ..style = PaintingStyle.stroke;

    // 繪製
    canvas.drawPath(path, paint);

    return path;
  }
}
