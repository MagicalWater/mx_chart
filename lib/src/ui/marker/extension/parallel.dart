import 'package:flutter/material.dart';

import '../painter.dart';

/// 水平線
extension ParallelMarker on ChartMarkerPainter {
  /// 水平線
  void drawParallel(Canvas canvas, Size size, MarkerPath marker) {
    final data = marker.data;

    // 是否編輯中
    final isEdit = isMarkerEdit(data);

    final pos1 = data.positions.safeGet(0);
    final pos2 = data.positions.safeGet(1);
    final pos3 = data.positions.safeGet(2);

    // 偏移值
    final offset = getMarkerOffset(data);

    if (pos1 == null || pos2 == null || pos3 == null) {
      // 檢查是否為編輯模式
      if (isEdit) {
        // 是編輯模式, 允許
        print('編輯模式');
      } else {
        print('不是編輯模式');
        // 不是編輯模式, 不允許
        marker.path = null;
        marker.anchorPoint = [];
        return;
      }
    }

    final x1 = pos1?.safeGetX(data, painterValueInfo, period);
    final x2 = pos2?.safeGetX(data, painterValueInfo, period);
    var x3 = pos3?.safeGetX(data, painterValueInfo, period);

    final canPoint1Draw = pos1 != null && x1 != null;
    final canPoint2Draw = pos2 != null && x2 != null;
    final canPoint3Draw = pos3 != null && x3 != null;

    if (canPoint1Draw && canPoint2Draw && canPoint3Draw) {
      // 點3的x不可以超過點1, 點2
      x3 = x3.clamp(x1, x2);
    }

    // realPoint1,2 => 底部基準點
    // realPoint3,4 => 對應起始點, 結尾點
    // centerPoint1,2 => 中間起始點, 結尾點
    Offset? realPoint1,
        realPoint2,
        realPoint3,
        realPoint4,
        centerPoint1,
        centerPoint2;

    Offset? anchorPoint1;

    // 斜率, 截距
    double? slope, intercept;

    double? realX1, realX2, realX3, y1, y2, y3;

    if (canPoint1Draw) {
      y1 = pricePosition.priceToY(pos1.price);
      realX1 = painterValueInfo.displayXToRealX(x1);
      // 取得真實的點位
      realPoint1 = Offset(realX1, y1) + offset;
    }

    if (canPoint2Draw) {
      y2 = pricePosition.priceToY(pos2.price);
      realX2 = painterValueInfo.displayXToRealX(x2);
      // 取得真實的點位
      realPoint2 = Offset(realX2, y2) + offset;
    }

    if (canPoint3Draw) {

      y3 = pricePosition.priceToY(pos3.price);
      realX3 = painterValueInfo.displayXToRealX(x3!);
      // 取得真實的點位
      anchorPoint1 = Offset(realX3, y3) + offset;
    }

    if (canPoint1Draw && canPoint2Draw && canPoint3Draw) {

      // 取得斜率
      slope = (y2! - y1!) / (x2 - x1);
      // 取得截距
      intercept = y1 - slope * x1;

      // 取得第一條線中, 當x座標為x3位置的y為多少

      // 套入斜率以及截距取得y
      final x3BottomY = slope * x3! + intercept;

      final differenceY = y3! - x3BottomY;
      // print('點1 => $x1, $y1');
      // print('點2 => $x2, $y2');
      // print('點3 => $x3, $y3');

      realPoint3 = Offset(realX1!, y1 + differenceY) + offset;
      realPoint4 = Offset(realX2!, y2 + differenceY) + offset;

      centerPoint1 = Offset(realX1, y1 + (differenceY / 2)) + offset;
      centerPoint2 = Offset(realX2, y2 + (differenceY / 2)) + offset;
    }

    Path? extendPath;

    if (realPoint1 != null &&
        realPoint2 != null &&
        realPoint3 != null &&
        realPoint4 != null &&
        centerPoint1 != null &&
        centerPoint2 != null) {
      final path = Path();

      // 生成需要繪製的路徑
      // 原本線
      path
        ..moveTo(realPoint1.dx, realPoint1.dy)
        ..lineTo(realPoint2.dx, realPoint2.dy);

      // 對應線
      path
        ..moveTo(realPoint3.dx, realPoint3.dy)
        ..lineTo(realPoint4.dx, realPoint4.dy);

      extendPath = Path()
        ..moveTo(realPoint1.dx, realPoint1.dy)
        ..lineTo(realPoint2.dx, realPoint2.dy)
        ..lineTo(realPoint4.dx, realPoint4.dy)
        ..lineTo(realPoint3.dx, realPoint3.dy)
        ..close();

      // 中間線
      final line3 = Path()
        ..moveTo(centerPoint1.dx, centerPoint1.dy)
        ..lineTo(centerPoint2.dx, centerPoint2.dy);

      // 背景
      final bg = Path()
        ..moveTo(realPoint1.dx, realPoint1.dy)
        ..lineTo(realPoint2.dx, realPoint2.dy)
        ..lineTo(realPoint4.dx, realPoint4.dy)
        ..lineTo(realPoint3.dx, realPoint3.dy)
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
      drawPath(path: path, canvas: canvas, marker: marker, paint: paint);
      drawPath(
        path: line3,
        canvas: canvas,
        marker: marker,
        paint: paint..strokeWidth = 1,
      );
    }

    final anchorPointPath = drawAnchorPath(
      data: data,
      isEdit: isEdit,
      canvas: canvas,
      points: [realPoint1, realPoint2, anchorPoint1].whereType<Offset>(),
    );

    // print('繪製錨點: $realPoint1 => $realPoint2 => $anchorPoint1');

    marker.path = extendPath;
    marker.anchorPoint = anchorPointPath;
  }
}
