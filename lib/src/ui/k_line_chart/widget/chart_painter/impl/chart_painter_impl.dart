// import 'package:flutter/material.dart';
// import 'package:mx_chart/src/ui/k_line_chart/widget/chart_render/impl/drag_bar_background/ui_style/drag_bar_background_ui_style.dart';
//
// import '../../../chart_gesture/chart_gesture.dart';
// import '../../../model/model.dart';
// import '../../chart_render/impl/kdj_chart/ui_style/kdj_chart_ui_style.dart';
// import '../../chart_render/impl/macd_chart/ui_style/macd_chart_ui_style.dart';
// import '../../chart_render/impl/main_chart/ui_style/main_chart_ui_style.dart';
// import '../../chart_render/impl/rsi_chart/ui_style/rsi_chart_ui_style.dart';
// import '../../chart_render/impl/volume_chart/ui_style/volume_chart_ui_style.dart';
// import '../../chart_render/impl/wr_chart/ui_style/wr_chart_ui_style.dart';
// import '../chart_painter.dart';
// import 'chart_painter_paint_mixin.dart';
// import 'chart_painter_value_mixin.dart';
//
// export '../ui_style/k_line_chart_ui_style.dart';
//
// class ChartPainterImpl extends ChartPainter
//     with ChartPainterPaintMixin, ChartPainterValueMixin {
//   @override
//   final List<KLineData> datas;
//
//   /// 圖表高度占用設定
//   @override
//   final KLineChartUiStyle chartUiStyle;
//
//   /// 當前x軸縮放倍數
//   @override
//   double get scaleX => chartGesture.scaleX;
//
//   /// 主圖表ui風格
//   @override
//   final MainChartUiStyle mainChartUiStyle;
//
//   /// 成交量圖表ui風格
//   @override
//   final VolumeChartUiStyle volumeChartUiStyle;
//
//   /// MACD圖表ui風格
//   @override
//   final MACDChartUiStyle macdChartUiStyle;
//
//   /// RSI圖表ui風格
//   @override
//   final RSIChartUiStyle rsiChartUiStyle;
//
//   /// WR圖表ui風格
//   @override
//   final WRChartUiStyle wrChartUiStyle;
//
//   /// KDJ圖表ui風格
//   @override
//   final KDJChartUiStyle kdjChartUiStyle;
//
//   @override
//   final DragBarBackgroundUiStyle dragBarUiStyle;
//
//   /// 主圖表顯示的資料
//   @override
//   final MainChartState mainChartState;
//
//   /// 主圖表的技術指標線
//   @override
//   final MainChartIndicatorState mainChartIndicatorState;
//
//   /// 買賣量圖表
//   @override
//   final VolumeChartState volumeChartState;
//
//   /// 技術指標圖表
//   @override
//   final IndicatorChartState indicatorChartState;
//
//   /// 價格格式化
//   @override
//   final String Function(num price) priceFormatter;
//
//   /// 成交量格式化
//   @override
//   final String Function(num volume) volumeFormatter;
//
//   /// x軸日期時間格式化
//   @override
//   final String Function(DateTime dateTime) xAxisDateTimeFormatter;
//
//   @override
//   final IndicatorSetting indicatorSetting;
//
//   @override
//   double? get longPressY =>
//       chartGesture.isLongPress ? chartGesture.longPressY : null;
//
//   /// 價格標示y軸位置獲取
//   PricePositionGetter? pricePositionGetter;
//
//   /// 高度分配結果
//   void Function(ChartHeightCompute<Rect> compute)? onRect;
//
//   /// 主圖表的高度偏移
//   final double mainChartHeightOffset;
//
//   /// 圖表組件排序
//   final List<ChartComponent> componentSort;
//
//   /// 拖拉bar是否可以顯示
//   final bool canDragBarShow;
//
//   /// 拖拉bar是否顯示
//   final bool dragBar;
//
//   ChartPainterImpl({
//     required this.datas,
//     required ChartGesture chartGesture,
//     required this.chartUiStyle,
//     required this.mainChartState,
//     required this.mainChartIndicatorState,
//     required this.volumeChartState,
//     required this.indicatorChartState,
//     required this.mainChartUiStyle,
//     required this.macdChartUiStyle,
//     required this.volumeChartUiStyle,
//     required this.rsiChartUiStyle,
//     required this.wrChartUiStyle,
//     required this.kdjChartUiStyle,
//     required this.dragBarUiStyle,
//     required this.indicatorSetting,
//     required this.priceFormatter,
//     required this.volumeFormatter,
//     required this.xAxisDateTimeFormatter,
//     required ValueChanged<DrawContentInfo>? onDrawInfo,
//     required ValueChanged<LongPressData?>? onLongPressData,
//     required this.componentSort,
//     required this.dragBar,
//     required this.canDragBarShow,
//     this.pricePositionGetter,
//     this.onRect,
//     this.mainChartHeightOffset = 0,
//   }) : super(
//           chartGesture: chartGesture,
//           onDrawInfo: onDrawInfo,
//           onLongPressData: onLongPressData,
//         );
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // if (datas.isEmpty) {
//     //   canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
//     //   return;
//     // }
//     if (mainChartState == MainChartState.none &&
//         volumeChartState == VolumeChartState.none &&
//         indicatorChartState == IndicatorChartState.none) {
//       return;
//     }
//
//     // 初始化數值
//     initDataValue(size);
//
//     // 將整塊畫布依照比例切割成Rect分配給各個圖表
//     // 1. 主圖表
//     // 2. 買賣量圖表
//     // 3. 其餘技術線圖表
//     final computeRect = chartUiStyle.heightRatioSetting
//         .computeChartHeight(
//           totalHeight: size.height,
//           mainChartState: mainChartState,
//           volumeChartState: volumeChartState,
//           indicatorChartState: indicatorChartState,
//           mainChartHeightOffset: mainChartHeightOffset,
//           canDragBarShow: canDragBarShow,
//           dragBar: dragBar,
//         )
//         .toRect(size, componentSort: componentSort);
//
//     onRect?.call(computeRect);
//
//     // 繪製主圖
//     paintMainChart(
//       canvas: canvas,
//       rect: computeRect.main,
//       pricePositionGetter: pricePositionGetter,
//     );
//
//     // 繪製成交量圖
//     paintVolumeChart(canvas, computeRect.volume);
//
//     // 繪製技術線圖
//     paintIndicatorChart(canvas, computeRect.indicator);
//
//     // 繪製時間軸
//     paintTimeAxis(canvas, computeRect.timeline);
//
//     // 繪製拖拉bar的背景
//     paintDragBarBackground(
//       canvas: canvas,
//       rect: computeRect.dragBar,
//     );
//
//     // 主圖表數值軸
//     final rightValueRect = Rect.fromLTWH(
//       size.width - chartUiStyle.sizeSetting.rightSpace,
//       0,
//       chartUiStyle.sizeSetting.rightSpace,
//       size.height,
//     );
//
//     // 繪製數值軸
//     paintValueAxisLine(
//       canvas,
//       rightValueRect,
//       computeRect.timeline,
//     );
//
//     if (datas.isEmpty) {
//       return;
//     }
//
//     // 繪製長按豎線
//     paintLongPressCrossLine(
//       canvas,
//       size,
//       computeRect.main,
//       computeRect.timeline,
//     );
//
//     // 繪製長按時間
//     paintLongPressTime(canvas, computeRect.timeline);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
