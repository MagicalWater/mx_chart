
import '../../model/model.dart';
import '../chart_render/impl/kdj_chart/ui_style/kdj_chart_ui_style.dart';
import '../chart_render/impl/macd_chart/ui_style/macd_chart_ui_style.dart';
import '../chart_render/impl/main_chart/ui_style/main_chart_ui_style.dart';
import '../chart_render/impl/rsi_chart/ui_style/rsi_chart_ui_style.dart';
import '../chart_render/impl/volume_chart/ui_style/volume_chart_ui_style.dart';
import '../chart_render/impl/wr_chart/ui_style/wr_chart_ui_style.dart';
import 'ui_style/k_line_chart_ui_style.dart';

/// 顯示的資料
abstract class DataViewer {
  /// 視圖中, 顯示的第一個以及最後一個data的index
  abstract int startDataIndex, endDataIndex;

  /// 當前x軸縮放
  double get scaleX;

  /// 長按的y軸位置
  double? get longPressY;

  /// 圖表資料
  abstract final List<KLineData> datas;

  /// 圖表通用ui風格
  abstract final KLineChartUiStyle chartUiStyle;

  /// 主圖表ui風格
  abstract final MainChartUiStyle mainChartUiStyle;

  /// 成交量圖表ui風格
  abstract final VolumeChartUiStyle volumeChartUiStyle;

  /// macd圖表ui風格
  abstract final MACDChartUiStyle macdChartUiStyle;

  /// rsi圖表ui風格
  abstract final RSIChartUiStyle rsiChartUiStyle;

  /// wr圖表ui風格
  abstract final WRChartUiStyle wrChartUiStyle;

  /// kdj圖表ui風格
  abstract final KDJChartUiStyle kdjChartUiStyle;

  /// 主圖表顯示的資料
  abstract final MainChartState mainChartState;

  /// 主圖表的技術指標線
  abstract final MainChartIndicatorState mainChartIndicatorState;

  /// 買賣量圖表
  abstract final VolumeChartState volumeChartState;

  /// 技術指標圖表
  abstract final IndicatorChartState indicatorChartState;

  /// 技術指標設定
  abstract final IndicatorSetting indicatorSetting;

  /// 價格格式化
  abstract final String Function(num price) priceFormatter;

  /// 成交量格式化
  abstract final String Function(num volume) volumeFormatter;

  /// x軸日期時間格式化
  abstract final String Function(DateTime dateTime) xAxisDateTimeFormatter;

  /// 取得長按中的data index
  int? getLongPressDataIndex();

  /// 取得長按中的data
  KLineData? getLongPressData();

  /// 將data的索引值轉換為畫布繪製的x軸座標
  double dataIndexToRealX(int index);

  /// 將畫布繪製的x軸座標轉換為data的索引值
  int realXToDataIndex(double realX);
}
