import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/extension/extension.dart';
import 'package:path_drawing/path_drawing.dart';

import '../k_line_chart/model/model.dart';
import 'model/model.dart';

export 'model/model.dart';

/// 圖表標記繪製
class ChartMarkerPainter extends CustomPainter {
  /// 繪製資訊
  final ChartPainterValueInfo painterValueInfo;

  /// 標記列表
  final List<MarkerPath> markers;

  /// 標記對應的偏移
  final Map<MarkerData, Offset>? markerOffset;

  /// y軸的價格位置
  final PricePosition pricePosition;

  /// 圖表的x軸時間軸週期
  final Duration period;

  /// 取得顯示的第一筆資料
  late KLineData startData;
  late KLineData endData;

  /// 取得第一筆與最後一筆資料的x軸位置
  late double startDataDisplayX;

  late double endDataDisplayX;

  /// 取得第一筆資料與最後一筆資料在畫布上的x軸位置
  late double startDataCanvasX;
  late double endDataCanvasX;

  /// 畫布最右側的x軸位置
  late double canvasRightX;

  /// 當算出所有的繪製路徑時回調
  /// 方便外部取得路徑並判斷點擊事件
  void Function(List<MarkerPath> path)? onPathsReady;

  /// 價格格式化
  final String Function(num price) priceFormatter;

  /// 當前的marker模式
  final MarkerMode markerMode;

  /// 當前編輯的marker資料
  final String? editId;

  /// 擴展path點擊半徑
  final double extendPathClickRadius = 10;

  ChartMarkerPainter({
    required this.markers,
    required this.painterValueInfo,
    required this.pricePosition,
    required this.period,
    required this.priceFormatter,
    required this.markerMode,
    this.markerOffset,
    this.editId,
    this.onPathsReady,
  });

  // 取得marker是否正在編輯中
  bool isMarkerEdit(MarkerData data) {
    return (markerMode.isAdd || markerMode.isEdit) && editId == data.id;
  }

  /// 取得marker的偏移值
  Offset getMarkerOffset(MarkerData data) {
    return markerOffset?[data] ?? Offset.zero;
  }

  /// 繪製外框線路徑
  void drawPath({
    required Path path,
    required Canvas canvas,
    required MarkerPath marker,
    required Paint paint,
  }) {
    if (marker.data.dashArray.isNotEmpty) {
      // 虛線路徑
      final toDash = dashPath(
        path,
        dashArray: CircularIntervalList(marker.data.dashArray),
      );
      canvas.drawPath(toDash, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  /// 繪製錨點
  /// [extendClickableRadius] - 擴展點擊半徑
  List<Path> drawAnchorPath({
    required MarkerData data,
    required bool isEdit,
    required Canvas canvas,
    required Iterable<Offset> points,
    double extendClickableRadius = 5,
  }) {
    final anchorPointPath = <Path>[];

    // 最後若為編輯模式, 還需加上錨點路徑
    if (isEdit) {
      final paint = Paint()
        ..color = data.color
        ..style = PaintingStyle.fill;

      for (var element in points) {
        final anchorPath = Path()..moveTo(element.dx, element.dy);
        final anchorShadowPath = Path()..moveTo(element.dx, element.dy);
        final extendAnchorPath = Path()..moveTo(element.dx, element.dy);

        final size = data.anchorPointRadius * 2;
        final rect = Rect.fromCenter(
          center: element,
          width: size,
          height: size,
        );
        final shadowRect = Rect.fromCenter(
          center: element,
          width: size + extendClickableRadius,
          height: size + extendClickableRadius,
        );
        final extendRect = Rect.fromCenter(
          center: element,
          width: size + extendClickableRadius * 2,
          height: size + extendClickableRadius * 2,
        );

        anchorPath.addOval(rect);
        anchorShadowPath.addOval(shadowRect);
        extendAnchorPath.addOval(extendRect);
        anchorPointPath.add(extendAnchorPath);

        canvas.drawPath(anchorShadowPath, paint..color = data.color.withOpacity(0.5));
        canvas.drawPath(anchorPath, paint..color = data.color);

      }
    }
    return anchorPointPath;
  }

  @override
  void paint(Canvas canvas, Size size) {
    startData = painterValueInfo.datas[painterValueInfo.startDataIndex];
    endData = painterValueInfo.datas[painterValueInfo.endDataIndex];

    startDataDisplayX =
        painterValueInfo.dataIndexToDisplayX(painterValueInfo.startDataIndex);
    endDataDisplayX =
        painterValueInfo.dataIndexToDisplayX(painterValueInfo.endDataIndex);

    startDataCanvasX =
        painterValueInfo.dataIndexToRealX(painterValueInfo.startDataIndex);
    endDataCanvasX =
        painterValueInfo.dataIndexToRealX(painterValueInfo.endDataIndex);

    canvasRightX = size.width;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // print('繪製標記的尺寸size => $size');

    // 一個一個循環需要繪製的資料
    for (var element in markers) {
      switch (element.data.type) {
        case MarkerType.trendLine:
          drawTrendLine(canvas, size, element);
          break;
        case MarkerType.extendTrendLine:
          drawExtendTrendLine(canvas, size, element);
          break;
        case MarkerType.ray:
          drawRay(canvas, size, element);
          break;
        case MarkerType.horizontalTrade:
          drawHorizontalTrade(canvas, size, element);
          break;
        case MarkerType.horizontalExtend:
          drawHorizontalExtend(canvas, size, element);
          break;
        case MarkerType.verticalExtend:
          drawVerticalExtend(canvas, size, element);
          break;
        case MarkerType.parallel:
          drawParallel(canvas, size, element);
          break;
        case MarkerType.priceLine:
          drawPriceLine(canvas, size, element);
          break;
        case MarkerType.waveLine3:
          drawWaveLine3(canvas, size, element);
          break;
        case MarkerType.rectangle:
          drawRectangle(canvas, size, element);
          break;
        case MarkerType.fibonacci:
          //TODO: 繪製斐波那契線
          break;
      }
    }

    canvas.restore();

    onPathsReady?.call(markers);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ChartMarkerPainter) {
      return true;
    }
    return false;
  }
}

extension MarkerPositionXSafeGet on MarkerPosition {
  double? safeGetX(
    MarkerData data,
    ChartPainterValueInfo painterValueInfo,
    Duration period,
  ) {
    return painterValueInfo.timeToDisplayX(
          dateTime,
          percent: xRate,
        ) ??
        painterValueInfo.estimateTimeToDisplayX(
          dateTime,
          period: period,
          percent: xRate,
        );
  }
}

extension MarkerPositionSafeGet on List<MarkerPosition> {
  MarkerPosition? safeGet(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return this[index];
  }
}
