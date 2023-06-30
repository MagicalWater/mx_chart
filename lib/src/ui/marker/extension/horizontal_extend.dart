import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/chart_marker_painter.dart';

/// 水平延伸
extension HorizontalExtendMarker on ChartMarkerPainter {
  /// 橫版交易線(價格線)
  Path? drawHorizontalExtend(Canvas canvas, Size size, MarkerData data) {
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
    final realStartX = painterValueInfo.displayXToRealX(x1);
    final realEndX = painterValueInfo.displayXToRealX(x2);

    // y以第一個點為主
    final realStartY = pricePosition.priceToY(point1.price);

    // 生成需要繪製的路徑
    final path = Path()
      ..moveTo(realStartX, realStartY)
      ..lineTo(realEndX, realStartY);

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
