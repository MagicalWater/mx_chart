import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/marker/extension/extension.dart';

import '../k_line_chart/model/model.dart';
import 'model/model.dart';

export 'model/model.dart';

/// 圖表標記繪製
class ChartMarkerPainter extends CustomPainter {
  /// 繪製資訊
  final ChartPainterValueInfo painterValueInfo;

  /// 標記列表
  final List<MarkerData> markers;

  /// y軸的價格位置
  final PricePosition pricePosition;

  /// 圖表的x軸時間軸週期
  final Duration period;

  /// 取得顯示的第一筆資料
  late final KLineData startData;
  late final KLineData endData;

  /// 取得第一筆與最後一筆資料的x軸位置
  late final double startDataDisplayX;

  late final double endDataDisplayX;

  /// 取得第一筆資料與最後一筆資料在畫布上的x軸位置
  late final double startDataCanvasX;
  late final double endDataCanvasX;

  /// 畫布最右側的x軸位置
  late final double canvasRightX;

  /// 當算出所有的繪製路徑時回調
  /// 方便外部取得路徑並判斷點擊事件
  void Function(List<MarkerPath> path)? onPathsReady;

  /// 價格格式化
  final String Function(num price) priceFormatter;

  ChartMarkerPainter({
    required this.markers,
    required this.painterValueInfo,
    required this.pricePosition,
    required this.period,
    required this.priceFormatter,
    this.onPathsReady,
  });

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
    canvas.clipRect(Rect.fromLTWH(
      0,
      0,
      size.width - painterValueInfo.sizeSetting.rightSpace,
      size.height,
    ));

    // print('繪製標記的尺寸size => $size');

    final markerPaths = <MarkerPath>[];

    // 一個一個循環需要繪製的資料
    for (var element in markers) {
      // print('標記類型 => ${element.type}');
      Path? path;
      switch (element.type) {
        case MarkerType.trendLine:
          path = drawTrendLine(canvas, size, element);
          break;
        case MarkerType.extendTrendLine:
          path = drawExtendTrendLine(canvas, size, element);
          break;
        case MarkerType.ray:
          path = drawRay(canvas, size, element);
          break;
        case MarkerType.horizontalTrade:
          path = drawHorizontalTrade(canvas, size, element);
          break;
        case MarkerType.horizontalExtend:
          path = drawHorizontalExtend(canvas, size, element);
          break;
        case MarkerType.verticalExtend:
          path = drawVerticalExtend(canvas, size, element);
          break;
        case MarkerType.parallel:
          // 平行線有兩條, 特別設置
          final multiPath = drawParallel(canvas, size, element);
          markerPaths.add(MarkerPath(
            data: element,
            path: multiPath?[0],
            path2: multiPath?[1],
          ));
          continue;
        case MarkerType.priceLine:
          path = drawPriceLine(canvas, size, element);
          break;
        case MarkerType.waveLine:
          path = drawWaveLine(canvas, size, element);
          break;
        case MarkerType.rectangle:
          path = drawRectangle(canvas, size, element);
          break;
        case MarkerType.fibonacci:
          //TODO: 繪製斐波那契線
          break;
      }
      markerPaths.add(MarkerPath(data: element, path: path));
    }

    canvas.restore();

    onPathsReady?.call(markerPaths);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ChartMarkerPainter) {
      return true;
    }
    return true;
  }
}
