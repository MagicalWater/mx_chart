import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/chart_marker_painter.dart';

/// 水平線
extension ParallelMarker on ChartMarkerPainter {
  /// 水平線
  List<Path>? drawParallel(Canvas canvas, Size size, MarkerData data) {
    // 取得三個點
    final point1 = data.positions[0];
    final point2 = data.positions[1];
    final point3 = data.positions[2];

    // 先取得前兩個點如同趨勢線算出斜率以及截距
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

    final x3 = painterValueInfo.timeToDisplayX(
          point3.dateTime,
          percent: point3.xRate,
        ) ??
        painterValueInfo.estimateTimeToDisplayX(
          point3.dateTime,
          period: period,
          percent: point3.xRate,
        );

    // 只要有一個點是null, 就不繪製
    if (x1 == null || x2 == null || x3 == null) {
      return null;
    }

    final y1 = pricePosition.priceToY(point1.price);
    final y2 = pricePosition.priceToY(point2.price);
    final y3 = pricePosition.priceToY(point3.price);

    // 取得斜率
    final slope = (y2 - y1) / (x2 - x1);

    // 取得截距
    final intercept = y1 - slope * x1;

    // 取得真實的x軸位置
    final realX1 = painterValueInfo.displayXToRealX(x1);
    final realX2 = painterValueInfo.displayXToRealX(x2);

    // 轉化為真實的y軸位置
    final realY1 = pricePosition.priceToY(point1.price);
    final realY2 = pricePosition.priceToY(point2.price);

    // 取得第一條線中, 在x座標為x3位置的y為多少

    // 套入斜率以及截距取得y
    final x3BottomY = slope * x3 + intercept;

    final differenceY = y3 - x3BottomY;

    // x3的原點y減去x3BottomY就是y個差距, 就可以取得對應的線的起始點以及結尾點
    final realY3Start = realY1 + differenceY;
    final realY3End = realY2 + differenceY;

    final realYCenterStart = realY1 + (differenceY / 2);
    final realYCenterEnd = realY2 + (differenceY / 2);

    // 生成需要繪製的路徑
    // 原本線
    final line1 = Path()
      ..moveTo(realX1, realY1)
      ..lineTo(realX2, realY2);

    // 對應線
    final line2 = Path()
      ..moveTo(realX1, realY3Start)
      ..lineTo(realX2, realY3End);

    // 中間線
    final line3 = Path()
      ..moveTo(realX1, realYCenterStart)
      ..lineTo(realX2, realYCenterEnd);

    // 背景
    final bg = Path()
      ..moveTo(realX1, realY1)
      ..lineTo(realX2, realY2)
      ..lineTo(realX2, realY3End)
      ..lineTo(realX1, realY3Start)
      ..close();

    final paint = Paint();

    // 生成繪製畫筆
    paint
      ..color = data.color
      ..strokeWidth = data.strokeWidth
      ..style = PaintingStyle.fill;

    canvas.drawPath(bg, paint..color = data.color.withOpacity(0.5));

    // 繪製底色
    paint
      ..color = data.color
      ..strokeWidth = data.strokeWidth
      ..style = PaintingStyle.stroke;

    // 繪製
    canvas.drawPath(line1, paint);
    canvas.drawPath(line2, paint);
    canvas.drawPath(line3, paint..strokeWidth = 1);

    return [line1, line2];
  }
}
