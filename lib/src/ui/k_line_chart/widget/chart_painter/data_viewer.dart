import 'package:mx_chart/src/ui/k_line_chart/view/k_line_chart.dart' show KLineChart;
import 'package:mx_chart/src/ui/k_line_chart/widget/chart_render/impl/drag_bar_background/drag_bar_background_render_impl.dart';

import '../../model/model.dart';
import '../chart_render/impl/kdj_chart/ui_style/kdj_chart_ui_style.dart';
import '../chart_render/impl/macd_chart/ui_style/macd_chart_ui_style.dart';
import '../chart_render/impl/main_chart/ui_style/main_chart_ui_style.dart';
import '../chart_render/impl/rsi_chart/ui_style/rsi_chart_ui_style.dart';
import '../chart_render/impl/volume_chart/ui_style/volume_chart_ui_style.dart';
import '../chart_render/impl/wr_chart/ui_style/wr_chart_ui_style.dart';
import 'ui_style/k_line_chart_ui_style.dart';

/// 顯示的資料
class DataViewer {
  /// 視圖中, 顯示的第一個以及最後一個data的index
  int get startDataIndex => valueInfo.startDataIndex;

  int get endDataIndex => valueInfo.endDataIndex;

  /// 當前x軸縮放
  double get scaleX => valueInfo.chartGesture.scaleX;

  /// 長按的y軸位置
  double? get longPressY => valueInfo.chartGesture.isLongPress
      ? valueInfo.chartGesture.longPressY
      : null;

  /// 長按的y軸資料
  KLineData? get longPressData => valueInfo.longPressData;

  /// 長案資料index
  int? get longPressDataIndex => valueInfo.longPressDataIndex;

  /// 圖表資料
  List<KLineData> get datas => valueInfo.datas;

  /// 圖表通用ui風格
  KLineChartUiStyle chartUiStyle;

  /// 主圖表ui風格ㄌ
  MainChartUiStyle mainChartUiStyle;

  /// 成交量圖表ui風格
  VolumeChartUiStyle volumeChartUiStyle;

  /// macd圖表ui風格
  MACDChartUiStyle macdChartUiStyle;

  /// rsi圖表ui風格
  RSIChartUiStyle rsiChartUiStyle;

  /// wr圖表ui風格
  WRChartUiStyle wrChartUiStyle;

  /// kdj圖表ui風格
  KDJChartUiStyle kdjChartUiStyle;

  /// 拖拉bar ui風格
  DragBarBackgroundUiStyle dragBarUiStyle;

  /// 主圖表顯示的資料
  MainChartState mainChartState;

  /// 主圖表的技術指標線
  MainChartIndicatorState mainChartIndicatorState;

  /// 買賣量圖表
  VolumeChartState volumeChartState;

  /// 技術指標圖表
  IndicatorChartState indicatorChartState;

  /// 技術指標設定
  IndicatorSetting indicatorSetting;

  /// 價格格式化
  String Function(num price) priceFormatter;

  /// 成交量格式化
  String Function(num volume) volumeFormatter;

  /// x軸日期時間格式化
  String Function(DateTime dateTime) xAxisDateTimeFormatter;

  final ChartPainterValueInfo valueInfo;

  DataViewer({
    required this.chartUiStyle,
    required this.mainChartUiStyle,
    required this.volumeChartUiStyle,
    required this.macdChartUiStyle,
    required this.rsiChartUiStyle,
    required this.wrChartUiStyle,
    required this.kdjChartUiStyle,
    required this.dragBarUiStyle,
    required this.mainChartState,
    required this.mainChartIndicatorState,
    required this.volumeChartState,
    required this.indicatorChartState,
    required this.indicatorSetting,
    required this.priceFormatter,
    required this.volumeFormatter,
    required this.xAxisDateTimeFormatter,
    required this.valueInfo,
  });

  void updateWithWidget(KLineChart widget) {
    chartUiStyle = widget.chartUiStyle;
    mainChartUiStyle = widget.mainChartUiStyle;
    volumeChartUiStyle = widget.volumeChartUiStyle;
    macdChartUiStyle = widget.macdChartUiStyle;
    rsiChartUiStyle = widget.rsiChartUiStyle;
    wrChartUiStyle = widget.wrChartUiStyle;
    kdjChartUiStyle = widget.kdjChartUiStyle;
    dragBarUiStyle = widget.dragBarBackgroundUiStyle;
    mainChartState = widget.mainChartState;
    mainChartIndicatorState = widget.mainChartIndicatorState;
    volumeChartState = widget.volumeChartState;
    indicatorChartState = widget.indicatorChartState;
    indicatorSetting = widget.indicatorSetting;
    priceFormatter = widget.priceFormatter;
    volumeFormatter = widget.volumeFormatter;
    xAxisDateTimeFormatter = widget.xAxisDateTimeFormatter;
  }

  /// 將data的索引值轉換為畫布繪製的x軸座標
  double dataIndexToRealX(int index) => valueInfo.dataIndexToRealX(index);

  /// 將畫布繪製的x軸座標轉換為data的索引值
  int realXToDataIndex(double realX) => valueInfo.realXToDataIndex(realX);
}
