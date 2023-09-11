import 'package:flutter/material.dart';

import '../painter.dart';
import '../reversible_path.dart';

/// 垂直延伸
extension VerticalExtendMarker on ChartMarkerPainter {
  /// 垂直延伸
  void drawVerticalExtend(Canvas canvas, Size size, MarkerPath marker) {
    final data = marker.data;

    // 是否編輯中
    final isEdit = isMarkerEdit(data);

    final pos1 = data.positions.safeGet(0);
    final pos2 = data.positions.safeGet(1);

    // 偏移值
    final offset = getMarkerOffset(data);

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

    // x 將以第一個點為主
    final x1 = pos1?.safeGetX(data, painterValueInfo, period);

    final canPoint1Draw = pos1 != null && x1 != null;
    final canPoint2Draw = pos2 != null;

    Offset? realPoint1, realPoint2;

    double? realX, y1;
    if (canPoint1Draw) {
      y1 = pricePosition.priceToY(pos1.price);
      realX = painterValueInfo.displayXToRealX(x1);

      // 取得真實的點位
      realPoint1 = Offset(realX, y1) + offset;
    }

    if (canPoint1Draw && canPoint2Draw) {
      final y2 = pricePosition.priceToY(pos2.price);
      realPoint2 = Offset(realX!, y2) + offset;
    }

    // 擴展點擊範圍的path
    Path? extendPath;

    if (realPoint1 != null && realPoint2 != null) {
      // 生成需要繪製的路徑
      final path = ReversiblePath()
        ..moveTo(realPoint1.dx, realPoint1.dy)
        ..lineTo(realPoint2.dx, realPoint2.dy);

      extendPath = path.shift(Offset(-extendPathClickRadius, 0));
      final downPath = path.reverse().shift(Offset(extendPathClickRadius, 0));

      extendPath.extendWithPath(downPath, Offset.zero);
      extendPath.moveTo(realPoint1.dx, realPoint1.dy);

      // 生成繪製畫筆
      final paint = Paint()
        ..color = data.color
        ..strokeWidth = data.strokeWidth
        ..style = PaintingStyle.stroke;

      // 繪製
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
