import 'dart:math';

import 'package:flutter/material.dart';

import '../../wr_chart_render.dart';

mixin WRChartValueMixin on WRChartRender {
  /// 資料檢視區間的最小值/最大值
  late double minValue, maxValue;

  /// 顯示的y軸位置區間
  /// [maxValue] 對應[minY]
  /// [minValue] 對應[maxY]
  late double minY, maxY;

  /// 快速將 value 轉換為 y軸位置的縮放參數
  late double _valueToYScale;

  final Paint backgroundPaint = Paint();
  final Paint gridPaint = Paint();
  final Paint linePaint = Paint()..style = PaintingStyle.stroke;

  WRChartUiStyle get uiStyle => dataViewer.wrChartUiStyle;

  WRChartColorSetting get colors => uiStyle.colorSetting;

  WRChartSizeSetting get sizes => uiStyle.sizeSetting;

  /// 最大最小值是否相同(代表為一條線)
  late bool isMinMaxValueEqual;

  @override
  void initValue(Rect rect) {
    minY = rect.top + sizes.topPadding;
    maxY = rect.bottom - sizes.bottomPadding;

    // 取得顯示區間的資料的最大值
    maxValue = -double.infinity;
    minValue = double.infinity;

    // 遍歷取得最大最小值, 以及擁有最大最小值的資料index
    for (var i = dataViewer.startDataIndex; i <= dataViewer.endDataIndex; i++) {
      final data = dataViewer.datas[i];
      final wrData = data.indicatorData.wr?.wr;

      if (wrData == null || wrData.isEmpty) {
        continue;
      }

      final values = wrData.values;
      final maxReduce = values.reduce(max);
      final minReduce = values.reduce(min);

      if (maxValue <= maxReduce) {
        maxValue = maxReduce;
      }

      if (minValue >= minReduce) {
        minValue = minReduce;
      }
    }

    if (minValue == double.infinity || maxValue == -double.infinity) {
      minValue = 0;
      maxValue = 0;
    }

    isMinMaxValueEqual = minValue == maxValue;

    // 最大最小值相同, 上下增減10%, 再加減5
    if (isMinMaxValueEqual) {
      minValue = minValue * 0.9 - 5;
      maxValue = maxValue * 1.1 + 5;
    }

    // 取得 value 快速轉換 y軸位置的縮放參數
    final valueInterval = maxValue - minValue;
    final yInterval = maxY - minY;
    _valueToYScale = yInterval / valueInterval;
  }

  /// 帶入數值, 取得顯示的y軸位置
  double valueToRealY(double value) {
    return maxY - ((value - minValue) * _valueToYScale);
  }

  /// 帶入y軸位置, 取得對應數值
  double realYToValue(double y) {
    return minValue - ((y - maxY) / _valueToYScale);
  }
}
