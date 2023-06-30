import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/chart_marker_painter.dart';

/// 連波線
extension WaveLineMarker on ChartMarkerPainter {
  /// 連波線
  Path? drawWaveLine(Canvas canvas, Size size, MarkerData data) {
    // 取得所有
    final points = data.positions;

    // 取得所有點的x座標
    final xList = points.map((e) {
      return painterValueInfo.timeToDisplayX(
            e.dateTime,
            percent: e.xRate,
          ) ??
          painterValueInfo.estimateTimeToDisplayX(
            e.dateTime,
            period: period,
            percent: e.xRate,
          );
    }).toList();

    // 只要有一個點是null, 就不繪製
    if (xList.any((element) => element == null)) {
      return null;
    }

    // 取得真實的x軸位置
    final realXList = xList.map((e) => painterValueInfo.displayXToRealX(e!)).toList();

    // 轉化為真實的y軸位置
    final realYList = points.map((e) => pricePosition.priceToY(e.price)).toList();

    // 生成需要繪製的路徑
    final path = Path();

    // path依照x, y列表的路線依序繪製
    for (var i = 0; i < realXList.length; i++) {
      final x = realXList[i];
      final y = realYList[i];

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

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
