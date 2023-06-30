import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/chart_marker_painter.dart';

extension ExtendTrendLineMarker on ChartMarkerPainter {
  /// 延伸趨勢線
  Path? drawExtendTrendLine(Canvas canvas, Size size, MarkerData data) {
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

    final y1 = pricePosition.priceToY(point1.price);
    final y2 = pricePosition.priceToY(point2.price);

    // 取得斜率
    final slope = (y2 - y1) / (x2 - x1);

    // 取得截距
    final intercept = y1 - slope * x1;

    // 取得真實的x軸位置
    const realStartX = 0.0;
    final realEndX = canvasRightX;

    // 套入斜率以及截距取得y
    final startLinePriceY =
        slope * painterValueInfo.realXToDisplayX(realStartX) + intercept;
    final endLinePriceY =
        slope * painterValueInfo.realXToDisplayX(realEndX) + intercept;

    // 生成需要繪製的路徑
    final path = Path()
      ..moveTo(realStartX, startLinePriceY)
      ..lineTo(realEndX, endLinePriceY);

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
