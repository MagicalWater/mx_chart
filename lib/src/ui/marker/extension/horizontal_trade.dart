import 'package:flutter/material.dart';

import '../reversible_path.dart';
import '../painter.dart';

/// 橫版交易線
extension HorizontalTradeMarker on ChartMarkerPainter {
  /// 橫版交易線(貫穿全圖表的價格線)
  void drawHorizontalTrade(Canvas canvas, Size size, MarkerPath marker) {
    final data = marker.data;

    // 是否編輯中
    final isEdit = isMarkerEdit(data);

    final pos1 = data.positions.safeGet(0);

    // 偏移值
    final offset = getMarkerOffset(data);

    if (pos1 == null) {
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

    final canPoint1Draw = pos1 != null;

    Offset? realPoint1, realPoint2;
    Offset? anchorPoint1;

    if (canPoint1Draw) {
      // 由於是貫穿整個圖表的線, 所以不用管x
      // 轉化為真實的y軸位置
      final y1 = pricePosition.priceToY(pos1.price);

      realPoint1 = Offset(0.0, y1 + offset.dy);
      realPoint2 = Offset(canvasRightX, y1 + offset.dy);

      if (x1 != null) {
        anchorPoint1 = Offset(x1, y1) + offset;
      }
    }

    // 擴展點擊範圍的path
    Path? extendPath;

    if (realPoint1 != null && realPoint2 != null) {
      // 生成需要繪製的路徑
      final path = ReversiblePath()
        ..moveTo(realPoint1.dx, realPoint1.dy)
        ..lineTo(realPoint2.dx, realPoint2.dy);

      extendPath = path.entity.shift(Offset(0, -extendPathClickRadius));
      final downPath = path.reverse().shift(Offset(0, extendPathClickRadius));

      extendPath.extendWithPath(downPath, Offset.zero);
      extendPath.moveTo(realPoint1.dx, realPoint1.dy);

      // 生成繪製畫筆
      final paint = Paint()
        ..color = data.color
        ..strokeWidth = data.strokeWidth
        ..style = PaintingStyle.stroke;

      // 繪製
      drawPath(path: path.entity, canvas: canvas, marker: marker, paint: paint);
    }

    final anchorPointPath = drawAnchorPath(
      data: data,
      isEdit: isEdit,
      canvas: canvas,
      points: [anchorPoint1].whereType<Offset>(),
    );

    marker.path = extendPath;
    marker.anchorPoint = anchorPointPath;
  }
}
