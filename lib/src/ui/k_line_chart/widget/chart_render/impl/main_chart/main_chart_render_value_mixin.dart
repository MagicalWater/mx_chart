import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../model/model.dart';
import '../../main_chart_render.dart';

mixin MainChartValueMixin on MainChartRender {
  /// 資料檢視區間擁有最小值/最大值的資料index
  late int minValueDataIndex, maxValueDataIndex;

  /// 資料檢視區間的最小值/最大值
  late double minValue, maxValue;

  /// 顯示的y軸位置區間
  /// [maxValue] 對應[minY]
  /// [minValue] 對應[maxY]
  late double minY, maxY;

  /// 快速將 value 轉換為 y軸位置的縮放參數
  late double _valueToYScale;

  /// 蠟燭圖的蠟燭寬度(已乘上縮放)
  late double candleWidthScaled;

  /// 每筆資料寬度(已乘上縮放)
  late double dataWidthScaled;

  /// 實時線畫筆
  final Paint realTimeLinePaint = Paint();

  /// 背景色畫筆
  final Paint backgroundPaint = Paint();

  /// 分隔線畫筆
  final Paint gripPaint = Paint();

  /// 折線/ma線/boll線畫筆
  final Paint linePaint = Paint()..style = PaintingStyle.stroke;

  /// 折線圖的陰影渲染畫筆
  final Paint lineShadowPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  /// 交叉橫線畫筆
  final Paint crossHorizontalPaint = Paint()..isAntiAlias = true;

  final chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5;

  MainChartUiStyle get uiStyle => dataViewer.mainChartUiStyle;

  MainChartColorSetting get colors => uiStyle.colorSetting;

  MainChartSizeSetting get sizes => uiStyle.sizeSetting;

  MainChartState get chartState => dataViewer.mainChartState;

  MainChartIndicatorState get indicatorState =>
      dataViewer.mainChartIndicatorState;

  /// 是否顯示k線
  late final bool isShowKLine;

  /// 是否顯示收盤價折線
  late final bool isShowLineIndex;

  /// 是否顯示ma線
  late final bool isShowMa;

  /// 是否顯示boll線
  late final bool isShowBoll;

  /// 最大最小值是否相同(代表為一條線)
  late final bool isMinMaxValueEqual;

  @override
  void initValue(Rect rect) {
    minY = rect.top + sizes.topPadding;
    maxY = rect.bottom - sizes.bottomPadding;

    // 取得顯示區間的資料的最大值
    maxValue = 0;
    minValue = double.infinity;

    isShowKLine = chartState == MainChartState.kLine;
    isShowLineIndex = chartState == MainChartState.lineIndex;

    isShowMa = indicatorState == MainChartIndicatorState.ma;
    isShowBoll = indicatorState == MainChartIndicatorState.boll;

    // 遍歷取得最大最小值, 以及擁有最大最小值的資料index
    for (var i = dataViewer.startDataIndex; i <= dataViewer.endDataIndex; i++) {
      final data = dataViewer.datas[i];

      if (isShowLineIndex) {
        // 折線圖只有收盤價
        if (maxValue <= data.close) {
          maxValue = data.close;
          maxValueDataIndex = i;
        }
        if (minValue >= data.close) {
          minValue = data.close;
          minValueDataIndex = i;
        }
      } else {
        if (maxValue <= data.high) {
          maxValue = data.high;
          maxValueDataIndex = i;
        }
        if (minValue >= data.low) {
          minValue = data.low;
          minValueDataIndex = i;
        }

        if (isShowMa) {
          final maData = data.indicatorData.ma?.ma;
          if (maData != null && maData.isNotEmpty) {
            final values = maData.values;
            final maxReduce = values.reduce(max);
            final minReduce = values.reduce(min);

            if (maxValue <= maxReduce) {
              maxValue = maxReduce;
              maxValueDataIndex = i;
            }

            if (minValue >= minReduce) {
              minValue = minReduce;
              minValueDataIndex = i;
            }
          }
        }

        if (isShowBoll) {
          final bollData = data.indicatorData.boll;
          if (bollData != null) {
            final values = [bollData.up, bollData.dn, bollData.mb];

            final maxReduce = values.reduce(max);
            final minReduce = values.reduce(min);

            if (maxValue <= maxReduce) {
              maxValue = maxReduce;
              maxValueDataIndex = i;
            }

            if (minValue >= minReduce) {
              minValue = minReduce;
              minValueDataIndex = i;
            }
          }
        }
      }
    }

    if (minValue == double.infinity || maxValue == 0) {
      minValue = 0;
      maxValue = 0;
    }

    isMinMaxValueEqual = minValue == maxValue;

    // 最大最小值相同, 上下增減10%, 再加減5
    if (isMinMaxValueEqual) {
      minValue = minValue * 0.9 - 5;
      maxValue = maxValue * 1.1 + 5;
    }

    dataWidthScaled =
        dataViewer.chartUiStyle.sizeSetting.dataWidth * dataViewer.scaleX;
    candleWidthScaled = sizes.candleWidth * dataViewer.scaleX;

    // 取得 value 快速轉換 y軸位置的縮放參數
    final valueInterval = maxValue - minValue;
    final yInterval = maxY - minY;
    // print('最大: $maxValue => $minY, 最小: $minValue => $maxY');
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
