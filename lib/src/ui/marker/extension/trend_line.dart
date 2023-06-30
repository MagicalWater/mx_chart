import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/chart_marker_painter.dart';

/// 趨勢線繪製擴展
extension TrendLineMarker on ChartMarkerPainter {
  /// 趨勢線
  Path? drawTrendLine(Canvas canvas, Size size, MarkerData data) {
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

    // final y1 = pricePosition.priceToY(point1.price);
    // final y2 = pricePosition.priceToY(point2.price);

    // // 取得斜率
    // final slope = (y2 - y1) / (x2 - x1);
    //
    // // 取得截距
    // final intercept = y1 - slope * x1;

    // 套入斜率以及截距取得y
    // final startLinePrice = slope * startDataDisplayX + intercept;
    // final endLinePriceY = slope * endDataDisplayX + intercept;

    // 取得真實的x軸位置
    final realStartX = painterValueInfo.displayXToRealX(x1);
    final realEndX = painterValueInfo.displayXToRealX(x2);

    // 轉化為真實的y軸位置
    final realStartY = pricePosition.priceToY(point1.price);
    final realEndY = pricePosition.priceToY(point2.price);

    // 打印所有參數, 用換行符號隔開
    // print('''
    // 繪製趨勢線
    // 繪製資料 => $data
    // 繪製資料的位置 => ${data.positions}
    // 繪製資料的顏色 => ${data.color}
    // 繪製資料的線寬 => ${data.strokeWidth}
    // 原始資料座標 => ($x1, $y1), ($x2, $y2)
    // 繪製資料的起始點x軸位置 => $startDataDisplayX
    // 繪製資料的結束點x軸位置 => $endDataDisplayX
    // 繪製資料的起始點真實座標 => ($realStartX, $realStartY)
    // 繪製資料的結束點真實座標 => ($realEndX, $realEndY)
    // ''');

    // 生成需要繪製的路徑
    final path = Path()
      ..moveTo(realStartX, realStartY)
      ..lineTo(realEndX, realEndY);

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
