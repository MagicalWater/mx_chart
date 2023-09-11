import 'package:flutter/material.dart';

import '../reversible_path.dart';
import '../painter.dart';

/// 3連波線
extension WaveLine3Marker on ChartMarkerPainter {
  /// 3連波線
  void drawWaveLine3(Canvas canvas, Size size, MarkerPath marker) {
    final data = marker.data;

    // 是否編輯中
    final isEdit = isMarkerEdit(data);

    // 偏移值
    final offset = getMarkerOffset(data);

    // 取得所有
    final points = data.positions;

    // 取得所有點的x座標
    final xList = points
        .map((e) => e.safeGetX(
              data,
              painterValueInfo,
              period,
            ))
        .toList();

    // 取得真實的位置
    final realPointList = List.generate(points.length, (index) {
      final x = xList[index];

      if (x == null) {
        return null;
      }

      return Offset(
            painterValueInfo.displayXToRealX(x),
            pricePosition.priceToY(points[index].price),
          ) +
          offset;
    });

    // 擴展點擊範圍的path
    Path? extendPath;

    // 只要有一個點是null, 就不繪製
    if (!realPointList.any((element) => element == null)) {
      // 生成需要繪製的路徑
      final path = ReversiblePath();

      // path依照x, y列表的路線依序繪製
      for (var i = 0; i < realPointList.length; i++) {
        final point = realPointList[i]!;
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      extendPath = path.shift(Offset(0, -extendPathClickRadius));
      final downPath = path.reverse().shift(Offset(0, extendPathClickRadius));

      extendPath.extendWithPath(downPath, Offset.zero);

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
      points: realPointList.whereType<Offset>(),
    );

    marker.path = extendPath;
    marker.anchorPoint = anchorPointPath;
  }
}
