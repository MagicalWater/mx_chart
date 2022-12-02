import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mx_chart/src/util/date_util.dart';

import '../../widget/position_layout.dart';
import '../chart_gesture/chart_gesture.dart';
import '../chart_gesture/impl/chart_gesture_impl.dart';
import '../chart_inertial_scroller/chart_inertial_scroller.dart';
import '../model/model.dart';
import '../widget/chart_painter/chart_painter.dart';
import '../widget/chart_render/kdj_chart_render.dart';
import '../widget/chart_render/macd_chart_render.dart';
import '../widget/chart_render/main_chart_render.dart';
import '../widget/chart_render/rsi_chart_render.dart';
import '../widget/chart_render/volume_chart_render.dart';
import '../widget/chart_render/wr_chart_render.dart';
import '../widget/flash_point/flast_point.dart';
import '../widget/height_rate_drag_bar.dart';
import '../widget/k_line_data_tooltip/k_line_data_tooltip.dart';
import '../widget/price_tag_line.dart';
import '../widget/touch_gesture_dector/touch_gesture_dector.dart';

export '../model/model.dart';
export '../widget/chart_painter/chart_painter.dart';
export '../widget/chart_render/kdj_chart_render.dart';
export '../widget/chart_render/macd_chart_render.dart';
export '../widget/chart_render/main_chart_render.dart';
export '../widget/chart_render/rsi_chart_render.dart';
export '../widget/chart_render/volume_chart_render.dart';
export '../widget/chart_render/wr_chart_render.dart';
export '../widget/k_line_data_tooltip/k_line_data_tooltip.dart';

part '../model/k_line_chart_controller.dart';

/// 長按tooltip構建
typedef KLineChartTooltipBuilder = Widget Function(
  BuildContext context,
  LongPressData data,
);

/// 價格標示構建
/// [rightSpace] - 最新價格距離圖表右側的距離, 若為0代表已不可見
/// [y] - 價格對應的y軸位置
typedef PriceTagBuilder = Widget Function(
  BuildContext context,
  PricePosition position,
);

/// k線圖表
/// ===
///
/// 起源自: https://github.com/gwhcn/flutter_k_chart
/// 非常感謝原作者在圖表上的製作思路
///
/// 了解完圖表的核心設計方式後, 進行了整體元件的重寫
/// 除了程式碼的結構差異之外, 在BUG/新增功能上
/// 1. 修正折線圖的光亮點造成整個圖表元件不斷的重構的問題
/// 2. 自定義手勢處理, 解決使用[GestureDetector]手勢縮放/拖拉沒有確實觸發的問題
/// 3. 圖表樣式/尺寸可由外部自由訂製
/// 4. 新增圖表滑動到最右側/最左側時會觸發加載更多的方法
/// 5. tooltip可由外部自由訂製顯示
/// 6. 點擊實時線的價格箭頭可彈跳至圖表最右側
/// 7. 初始資料未滿一頁時, 會自動觸發一次加載更多
/// 8. 圖表高度若皆為固定值, 則外部不需將高度設死
/// 9. 主圖表新增高度比例分配的拖曳bar
/// 10. 圖表不覆蓋到右方的數值軸, 在數值軸的左方加入分隔線
class KLineChart extends StatefulWidget {
  /// 圖表資料
  final List<KLineData> datas;

  /// 總ui
  final KLineChartUiStyle chartUiStyle;

  /// 主圖表的ui
  final MainChartUiStyle mainChartUiStyle;

  /// 成交量圖表的ui
  final VolumeChartUiStyle volumeChartUiStyle;

  /// macd技術線的ui
  final MACDChartUiStyle macdChartUiStyle;

  /// rsi技術線的ui
  final RSIChartUiStyle rsiChartUiStyle;

  /// wr技術線的ui
  final WRChartUiStyle wrChartUiStyle;

  /// kdj技術線的ui
  final KDJChartUiStyle kdjChartUiStyle;

  /// 主圖表顯示
  final MainChartState mainChartState;

  /// 主圖表技術線
  final MainChartIndicatorState mainChartIndicatorState;

  /// 成交量圖表顯示
  final VolumeChartState volumeChartState;

  /// 技術分析圖表顯示
  final IndicatorChartState indicatorChartState;

  /// 技術指標設定
  final IndicatorSetting indicatorSetting;

  /// x軸時間格式化
  final String Function(DateTime dateTime) xAxisDateTimeFormatter;

  /// tooltip 樣式
  final KLineDataTooltipUiStyle tooltipUiStyle;

  /// tooltip前綴字
  final TooltipPrefix tooltipPrefix;

  /// tooltip彈窗構建(若不帶入則使用預設彈窗)
  final KLineChartTooltipBuilder? tooltipBuilder;

  /// 加載更多調用, false代表滑動到最左邊, true則為最右邊
  final void Function(bool right)? onLoadMore;

  /// 價格格式化
  final String Function(num price) priceFormatter;

  /// 成交量格式化
  final String Function(num volume)? volumeFormatter;

  /// 圖表控制
  final KLineChartController? controller;

  /// 自訂價格展示元件(若帶入值將會取代預設的最新價格展示)
  final PriceTagBuilder? priceTagBuilder;

  /// 長按時, 觸發震動回饋
  final bool longPressVibrate;

  /// 主圖表下方的拖拉bar元件構建
  final Widget Function(BuildContext context, bool isLongPress)? dragBarBuilder;

  const KLineChart({
    Key? key,
    required this.datas,
    this.mainChartState = MainChartState.kLine,
    this.mainChartIndicatorState = MainChartIndicatorState.ma,
    this.volumeChartState = VolumeChartState.volume,
    this.indicatorChartState = IndicatorChartState.kdj,
    this.chartUiStyle = const KLineChartUiStyle(),
    this.mainChartUiStyle = const MainChartUiStyle(),
    this.volumeChartUiStyle = const VolumeChartUiStyle(),
    this.macdChartUiStyle = const MACDChartUiStyle(),
    this.rsiChartUiStyle = const RSIChartUiStyle(),
    this.wrChartUiStyle = const WRChartUiStyle(),
    this.kdjChartUiStyle = const KDJChartUiStyle(),
    this.indicatorSetting = const IndicatorSetting(),
    this.tooltipPrefix = const TooltipPrefix(),
    this.tooltipUiStyle = const KLineDataTooltipUiStyle(),
    this.tooltipBuilder,
    this.xAxisDateTimeFormatter = _defaultXAxisDateFormatter,
    this.priceFormatter = _defaultPriceFormatter,
    this.volumeFormatter,
    this.onLoadMore,
    this.controller,
    this.priceTagBuilder,
    this.longPressVibrate = true,
    this.dragBarBuilder,
  }) : super(key: key);

  /// 預設x軸時間格式化
  static String _defaultXAxisDateFormatter(DateTime dateTime) {
    return dateTime.getDateStr(format: 'MM-dd HH:mm');
  }

  /// 預設價格格式化
  static String _defaultPriceFormatter(num price) {
    return price.toStringAsFixed(2);
  }

  @override
  State<KLineChart> createState() => _KLineChartState();
}

class _KLineChartState extends State<KLineChart>
    with SingleTickerProviderStateMixin {
  /// 最新價格
  double? realTimePrice;

  /// 當前圖表的高度
  double? chartHeight;

  /// 當前長按的資料index
  int? longPressIndex;

  /// 訂閱的價格位置
  final _pricePositionStreamController = StreamController<PricePosition>();

  /// 價格標示位置串流
  late final Stream<PricePosition> _pricePositionStream;

  /// 圖表拖移處理
  late final ChartGesture chartGesture;

  /// 當資料未滿一頁時所記錄下的資料筆數
  /// 用途是當再次傳出資料筆數未滿一頁時
  /// 不再持續重複調用加載更多資料
  int oldDataCount = 0;

  /// 與[oldDataCount]搭配使用, 代表當頁數未滿一頁時, 是否已經調用過未滿一頁所觸發的回調了
  bool isDataLessOnePageCallBack = false;

  /// 長按的資料串流控制
  final _longPressDataStreamController = StreamController<LongPressData?>();

  /// 長按的資料串流
  late final Stream<LongPressData?> _longPressDataStream;

  /// scroll bar 的 rect
  final _scrollBarRectStreamController = StreamController<Rect>();

  /// scroll bar 的 rect 串流
  late final Stream<Rect> _scrollBarRectStream;

  /// 主圖表的高度偏移
  double mainChartHeightOffset = 0;

  /// 高度拖移由於是取得與原始位置的偏移, 而非每次移動的距離
  /// 因此在滑動開始前要先將當前原本的偏移存起來
  double oriMainChartHeightOffset = 0;

  @override
  void initState() {
    realTimePrice = widget.datas.lastOrNull?.close;

    _pricePositionStream = _pricePositionStreamController.stream.distinct();
    _longPressDataStream = _longPressDataStreamController.stream.distinct();
    _scrollBarRectStream = _scrollBarRectStreamController.stream.distinct();

    // 慣性滑動控制器
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );

    chartGesture = ChartGestureImpl(
      onDrawUpdateNeed: () => setState(() {}),
      chartScroller: ChartInertialScroller(controller: controller),
      onLoadMore: widget.onLoadMore,
    );

    oldDataCount = widget.datas.length;
    isDataLessOnePageCallBack = false;

    widget.controller?._bind = this;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant KLineChart oldWidget) {
    realTimePrice = widget.datas.lastOrNull?.close;

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._bind = null;
      widget.controller?._bind = this;
    }

    if (oldDataCount != widget.datas.length) {
      oldDataCount = widget.datas.length;
      isDataLessOnePageCallBack = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    chartGesture.dispose();
    _pricePositionStreamController.close();
    _longPressDataStreamController.close();
    _scrollBarRectStreamController.close();
    widget.controller?._bind = null;
    super.dispose();
  }

  /// 預設成交量格式化
  String _defaultVolumeFormatter(num volume) {
    if (volume > 10000 && volume < 999999) {
      final d = volume / 1000;
      return '${widget.priceFormatter(d)}K';
    } else if (volume > 1000000) {
      final d = volume / 1000000;
      return '${widget.priceFormatter(d)}M';
    }
    return widget.priceFormatter(volume);
  }

  @override
  Widget build(BuildContext context) {
    final heightSetting = widget.chartUiStyle.heightRatioSetting;
    chartHeight = heightSetting.getFixedHeight(
          volumeChartState: widget.volumeChartState,
          indicatorChartState: widget.indicatorChartState,
        ) ??
        double.infinity;
    return TouchGestureDector(
      onTouchStart: chartGesture.onTouchDown,
      onTouchUpdate: chartGesture.onTouchUpdate,
      onTouchEnd: chartGesture.onTouchUp,
      onTouchCancel: chartGesture.onTouchCancel,
      isAllowPointerMove: (move) {
        final touchStatus = chartGesture.getTouchPointerStatus(move.pointer);
        switch (touchStatus) {
          case TouchStatus.none:
            return GestureDisposition.rejected;
          case TouchStatus.drag:
            final hitSlop = computeHitSlop(move.kind, move.gestureSettings);
            if (move.pendingDelta.dx.abs() > hitSlop) {
              return GestureDisposition.accepted;
            }
            break;
          case TouchStatus.scale:
            return GestureDisposition.accepted;
          case TouchStatus.longPress:
            return GestureDisposition.accepted;
        }
        return null;
      },
      child: Stack(
        children: <Widget>[
          RepaintBoundary(
            child: CustomPaint(
              size: Size(double.infinity, chartHeight!),
              painter: ChartPainterImpl(
                datas: widget.datas,
                chartGesture: chartGesture,
                chartUiStyle: widget.chartUiStyle,
                mainChartState: widget.mainChartState,
                mainChartIndicatorState: widget.mainChartIndicatorState,
                volumeChartState: widget.volumeChartState,
                indicatorChartState: widget.indicatorChartState,
                mainChartUiStyle: widget.mainChartUiStyle,
                volumeChartUiStyle: widget.volumeChartUiStyle,
                macdChartUiStyle: widget.macdChartUiStyle,
                rsiChartUiStyle: widget.rsiChartUiStyle,
                wrChartUiStyle: widget.wrChartUiStyle,
                kdjChartUiStyle: widget.kdjChartUiStyle,
                indicatorSetting: widget.indicatorSetting,
                priceFormatter: widget.priceFormatter,
                volumeFormatter:
                    widget.volumeFormatter ?? _defaultVolumeFormatter,
                xAxisDateTimeFormatter: widget.xAxisDateTimeFormatter,
                mainChartHeightOffset: mainChartHeightOffset,
                onDrawInfo: (info) {
                  chartGesture.setDrawInfo(info);
                  if (info.maxScrollX == 0) {
                    // 資料未滿一頁
                    if (!isDataLessOnePageCallBack) {
                      isDataLessOnePageCallBack = true;
                      widget.onLoadMore?.call(false);
                    }
                  }
                },
                onLongPressData: (data) {
                  if (data != null && longPressIndex != data.index) {
                    // 發出震動
                    _vibrate();
                  }
                  longPressIndex = data?.index;
                  _longPressDataStreamController.add(data);
                },
                pricePositionGetter: (rightSpace, isNewerDisplay, valueToY) {
                  final position = PricePosition(
                    canvasWidth: chartGesture.drawContentInfo!.canvasWidth,
                    rightSpace: rightSpace,
                    valueToY: valueToY,
                    lastPrice: realTimePrice,
                    isNewerDisplay: isNewerDisplay,
                  );
                  _pricePositionStreamController.add(position);
                },
                onRect: (compute) {
                  _scrollBarRectStreamController.add(compute.scrollBar);
                },
              ),
            ),
          ),

          // 價格標示(包含閃亮點)
          _priceTagBuilder(),

          // 長按時顯示的詳細資訊彈窗
          _tooltip(),

          // 高度比例拖曳bar
          _heightRatioScrollBar(),
        ],
      ),
    );
  }

  /// 長按顯示的tooltip
  Widget _tooltip() {
    return StreamBuilder<LongPressData?>(
      stream: _longPressDataStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return widget.tooltipBuilder?.call(context, data) ??
              KLineDataInfoTooltip(
                longPressData: data,
                priceFormatter: widget.priceFormatter,
                volumeFormatter:
                    widget.volumeFormatter ?? _defaultVolumeFormatter,
                uiStyle: widget.tooltipUiStyle,
                tooltipPrefix: widget.tooltipPrefix,
              );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// 高度分配拖拉bar
  Widget _heightRatioScrollBar() {
    return StreamBuilder<Rect>(
      stream: _scrollBarRectStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final rect = snapshot.data!;

          // 最外層需要包裹在一樣的高度下, 否則實際點擊區塊會出問題
          return SizedBox(
            height: chartHeight,
            child: HeightRatioDragBar(
              rect: rect,
              chartUiStyle: widget.chartUiStyle,
              onDragStart: () {
                oriMainChartHeightOffset = mainChartHeightOffset;
              },
              onDragUpdate: (offset) {
                mainChartHeightOffset = oriMainChartHeightOffset + offset;
                setState(() {});
              },
              builder: widget.dragBarBuilder,
              enable: widget.volumeChartState != VolumeChartState.none ||
                  widget.indicatorChartState != IndicatorChartState.none,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// 價格標示構建
  Widget _priceTagBuilder() {
    return StreamBuilder<PricePosition>(
      stream: _pricePositionStream,
      builder: (context, snapshot) {
        final position = snapshot.data;
        if (realTimePrice == null || position == null) {
          return const SizedBox.shrink();
        }

        // 最新價格的標示
        final realTimePriceTag =
            widget.priceTagBuilder?.call(context, position) ??
                Stack(
                  children: [
                    _flashPoint(context, position),
                    _realTimePriceTag(context, position),
                  ],
                );

        return SizedBox(
          height: chartHeight,
          child: realTimePriceTag,
        );
      },
    );
  }

  /// 閃耀動畫
  Widget _flashPoint(BuildContext context, PricePosition position) {
    final circleSize = widget.mainChartUiStyle.sizeSetting.realTimePriceFlash;
    final pointSize = widget.mainChartUiStyle.sizeSetting.realTimePriceCircle;
    final flashColor =
        widget.mainChartUiStyle.colorSetting.realTimeRightPointFlash;
    final isLineIndex = widget.mainChartState == MainChartState.lineIndex;

    final isPointShow = isLineIndex && position.isNewerDisplay;
    if (!isPointShow) {
      return const SizedBox.shrink();
    }

    return PositionLayout(
      xFixed: position.canvasWidth - position.rightSpace,
      yFixed: position.valueToY(realTimePrice!),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: flashColor.first,
              shape: BoxShape.circle,
            ),
            width: pointSize * 2,
            height: pointSize * 2,
          ),
          RepaintBoundary(
            child: FlashPoint(
              active: true,
              width: circleSize,
              height: circleSize,
              flastColors: flashColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 預設的最新價格線標示
  Widget _realTimePriceTag(BuildContext context, PricePosition position) {
    final gridColumns = widget.chartUiStyle.sizeSetting.gridColumns;
    return PriceTagLine(
      gridColumns: gridColumns,
      price: realTimePrice!,
      position: position,
      uiStyle: widget.mainChartUiStyle,
      priceFormatter: widget.priceFormatter,
      globalTagOffsetX: widget.chartUiStyle.sizeSetting.rightSpace,
      onTapGlobalTag: () async {
        _vibrate();
        scrollToRight(animated: true);
      },
    );
  }

  /// 發出震動
  void _vibrate() async {
    if (!widget.longPressVibrate) {
      return;
    }
    if (Platform.isIOS) {
      // 此方法在android上失效
      await HapticFeedback.mediumImpact();
    } else if (Platform.isAndroid) {
      await HapticFeedback.mediumImpact();

      // 此套件在ios上失效
      // final hasVibrator = await Vibration.hasVibrator() ?? false;
      // final hasAmplitudeControl =
      //     await Vibration.hasAmplitudeControl() ?? false;
      // final hasCustomVibrationsSupport =
      //     await Vibration.hasCustomVibrationsSupport() ?? false;
      // if (hasVibrator) {
      //   if (hasAmplitudeControl && hasCustomVibrationsSupport) {
      //     print('震動1');
      //     await Vibration.vibrate(duration: 10, amplitude: 255);
      //   } else if (hasCustomVibrationsSupport) {
      //     print('震動2');
      //     await Vibration.vibrate(pattern: [0, 5], intensities: [255]);
      //   } else if (hasAmplitudeControl) {
      //     print('震動3');
      //     await Vibration.vibrate(amplitude: 255);
      //   } else {
      //     print('震動4');
      //     await Vibration.vibrate();
      //   }
      // }
    }
  }

  /// 將圖表滾動回原點
  Future<void> scrollToRight({bool animated = true}) {
    return chartGesture.scrollToRight(animated: animated);
  }
}
