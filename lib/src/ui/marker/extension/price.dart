import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/chart_marker_painter.dart';

/// 價格線
extension PriceMarker on ChartMarkerPainter {
  /// 價格線(與HorizontalTrade差別在於不會貫穿全圖表)
  Path? drawPriceLine(Canvas canvas, Size size, MarkerData data) {
    // 取得1個點
    final point1 = data.positions[0];

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

    if (x1 == null) {
      return null;
    }

    // 取得真實的x軸位置
    final realX = painterValueInfo.displayXToRealX(x1);

    // 轉化為真實的y軸位置
    final realY = pricePosition.priceToY(point1.price);

    // 生成需要繪製的路徑
    final path = Path()
      ..moveTo(realX, realY)
      ..lineTo(canvasRightX, realY);

    // 生成繪製畫筆
    final paint = Paint()
      ..color = data.color
      ..strokeWidth = data.strokeWidth
      ..style = PaintingStyle.stroke;

    // 加上價格文字
    final pricePainter = TextPainter(
      text: TextSpan(
        text: priceFormatter(point1.price),
        style: TextStyle(color: data.color, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );

    pricePainter.layout();

    pricePainter.paint(
      canvas,
      Offset(realX + 2, realY - pricePainter.height - 2),
    );

    // 繪製
    canvas.drawPath(path, paint);

    return path;
  }
}
