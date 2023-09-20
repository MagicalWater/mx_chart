import 'dart:math';

import 'package:flutter/material.dart';

import '../painter.dart';

/// 矩形
extension RectangleMarker on ChartMarkerPainter {
  /// 矩形
  void drawRectangle(Canvas canvas, Size size, MarkerPath marker) {
    final data = marker.data;

    // 是否編輯中
    final isEdit = isMarkerEdit(data);

    // 偏移值
    final offset = getMarkerOffset(data);

    // 偏移值的矩陣
    // final offsetMatrix4 = Matrix4.translationValues(offset.dx, offset.dy, 0);

    final pos1 = data.positions.safeGet(0);
    final pos2 = data.positions.safeGet(1);

    if (pos1 == null || pos2 == null) {
      // 檢查是否為編輯模式
      if (isEdit) {
        // 是編輯模式, 允許
      } else {
        // 不是編輯模式, 不允許
        marker.path = null;
        marker.anchorPoint = [];
        return;
      }
    }

    final x1 = pos1?.safeGetX(data, painterValueInfo, period);
    final x2 = pos2?.safeGetX(data, painterValueInfo, period);

    final canPoint1Draw = pos1 != null && x1 != null;
    final canPoint2Draw = pos2 != null && x2 != null;

    Offset? realPoint1, realPoint2;

    if (canPoint1Draw) {
      // 取得真實的點位
      realPoint1 = Offset(
            painterValueInfo.displayXToRealX(x1),
            pricePosition.priceToY(pos1.price),
          ) +
          offset;
    }

    if (canPoint2Draw) {
      // 取得真實的點位
      realPoint2 = Offset(
            painterValueInfo.displayXToRealX(x2),
            pricePosition.priceToY(pos2.price),
          ) +
          offset;
    }

    Path? extendPath;

    if (realPoint1 != null && realPoint2 != null) {
      // 生成需要繪製的路徑
      final path = Path()
        ..moveTo(realPoint1.dx, realPoint1.dy)
        ..lineTo(realPoint2.dx, realPoint1.dy)
        ..lineTo(realPoint2.dx, realPoint2.dy)
        ..lineTo(realPoint1.dx, realPoint2.dy)
        ..close();

      // 擴大點擊範圍
      final extendRect = Rect.fromPoints(
        Offset(
          min(realPoint1.dx, realPoint2.dx) - extendPathClickRadius,
          min(realPoint1.dy, realPoint2.dy) - extendPathClickRadius,
        ),
        Offset(
          max(realPoint1.dx, realPoint2.dx) + extendPathClickRadius,
          max(realPoint1.dy, realPoint2.dy) + extendPathClickRadius,
        ),
      );
      extendPath = Path()..addRect(extendRect);

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

      drawPath(path: path, canvas: canvas, marker: marker, paint: paint);
    }

    final anchorPointPath = drawAnchorPath(
      data: data,
      isEdit: isEdit,
      canvas: canvas,
      points: [realPoint1, realPoint2].whereType<Offset>(),
    );

    marker.path = extendPath;
    marker.anchorPoint = anchorPointPath;
  }
}
