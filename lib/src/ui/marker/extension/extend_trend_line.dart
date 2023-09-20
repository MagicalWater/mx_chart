import 'package:flutter/material.dart';

import '../painter.dart';
import '../reversible_path.dart';

extension ExtendTrendLineMarker on ChartMarkerPainter {
  /// 延伸趨勢線
  void drawExtendTrendLine(Canvas canvas, Size size, MarkerPath marker) {
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

    final x1 = pos1?.safeGetX(data, painterValueInfo, period);
    final x2 = pos2?.safeGetX(data, painterValueInfo, period);

    final canPoint1Draw = pos1 != null && x1 != null;
    final canPoint2Draw = pos2 != null && x2 != null;

    Offset? realPoint1, realPoint2;
    Offset? anchorPoint1, anchorPoint2;

    // 斜率, 截距
    double? slope, intercept;

    if (canPoint1Draw && canPoint2Draw) {
      final y1 = pricePosition.priceToY(pos1.price);
      final y2 = pricePosition.priceToY(pos2.price);

      // 取得斜率
      slope = (y2 - y1) / (x2 - x1);
      // 取得截距
      intercept = (y1 + offset.dy) - slope * (x1 + offset.dx);

      // 取得真實的點位
      realPoint1 = Offset(
            0.0,
            slope * painterValueInfo.realXToDisplayX(0.0) + intercept,
          );

      // final rightX =

      realPoint2 = Offset(
            canvasRightX,
            slope * painterValueInfo.realXToDisplayX(canvasRightX) + intercept,
          );
    }

    if (canPoint1Draw) {
      anchorPoint1 = Offset(
            painterValueInfo.displayXToRealX(x1),
            pricePosition.priceToY(pos1.price),
          ) +
          offset;
    }
    if (canPoint2Draw) {
      anchorPoint2 = Offset(
            painterValueInfo.displayXToRealX(x2),
            pricePosition.priceToY(pos2.price),
          ) +
          offset;
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

      // 繪製路徑
      drawPath(path: path.entity, canvas: canvas, marker: marker, paint: paint);
    }

    final anchorPointPath = drawAnchorPath(
      data: data,
      isEdit: isEdit,
      canvas: canvas,
      points: [anchorPoint1, anchorPoint2].whereType<Offset>(),
      extendClickableRadius: extendPathClickRadius,
    );

    marker.path = extendPath;
    marker.anchorPoint = anchorPointPath;
  }
}
