import 'package:flutter/material.dart';

import '../reversible_path.dart';
import '../painter.dart';

/// 價格線
extension PriceMarker on ChartMarkerPainter {
  /// 價格線(與HorizontalTrade差別在於不會貫穿全圖表)
  void drawPriceLine(Canvas canvas, Size size, MarkerPath marker) {
    final data = marker.data;

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

    final canPoint1Draw = pos1 != null && x1 != null;

    Offset? realPoint1, realPoint2;

    if (canPoint1Draw) {
      // 轉化為真實的y軸位置
      final y1 = pricePosition.priceToY(pos1.price);

      realPoint2 = Offset(canvasRightX, y1 + offset.dy);

      // 取得真實的x軸位置
      final realX = painterValueInfo.displayXToRealX(x1);

      realPoint1 = Offset(realX, y1) + offset;
    }

    // 擴展點擊範圍的path
    Path? extendPath;

    if (pos1 != null && realPoint1 != null && realPoint2 != null) {
      // 生成需要繪製的路徑
      final path = ReversiblePath()
        ..moveTo(realPoint1.dx, realPoint1.dy)
        ..lineTo(realPoint2.dx, realPoint2.dy);

      extendPath = path.shift(Offset(0, -extendPathClickRadius));
      final downPath = path.reverse().shift(Offset(0, extendPathClickRadius));

      extendPath.extendWithPath(downPath, Offset.zero);
      extendPath.moveTo(realPoint1.dx, realPoint1.dy);

      // 生成繪製畫筆
      final paint = Paint()
        ..color = data.color
        ..strokeWidth = data.strokeWidth
        ..style = PaintingStyle.stroke;

      // 加上價格文字
      final pricePainter = TextPainter(
        text: TextSpan(
          text: priceFormatter(pos1.price),
          style: TextStyle(color: data.color, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );

      pricePainter.layout();

      pricePainter.paint(
        canvas,
        Offset(realPoint1.dx + 2, realPoint1.dy - pricePainter.height - 2),
      );

      // 繪製
      drawPath(path: path, canvas: canvas, marker: marker, paint: paint);
    }

    final anchorPointPath = drawAnchorPath(
      data: data,
      isEdit: isEdit,
      canvas: canvas,
      points: [realPoint1].whereType<Offset>(),
    );

    marker.path = extendPath;
    marker.anchorPoint = anchorPointPath;
  }
}
