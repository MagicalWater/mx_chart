import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/chart_marker_painter.dart';

/// 橫版交易線
extension HorizontalTradeMarker on ChartMarkerPainter {
  /// 橫版交易線(貫穿全圖表的價格線)
  Path? drawHorizontalTrade(Canvas canvas, Size size, MarkerData data) {
    // 取得1個點
    final point1 = data.positions[0];

    // 由於是貫穿整個圖表的線, 所以不用管x
    // 轉化為真實的y軸位置
    final realY = pricePosition.priceToY(point1.price);

    // 生成需要繪製的路徑
    final path = Path()
      ..moveTo(0, realY)
      ..lineTo(canvasRightX, realY);

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
