// ignore_for_file: hash_and_equals

import '../../../model/chart_state/chart_state.dart';

/// 圖表占用高度設定
class ChartHeightRatioSetting {
  /// 主圖表固定高度
  final double? mainFixed;

  /// 主圖表高度比例
  final double? mainRatio;

  /// 買賣圖表固定高度
  final double? volumeFixed;

  /// 買賣圖表高度比例
  final double? volumeRatio;

  /// 其餘技術線圖表固定高度
  final double? indicatorFixed;

  /// 其餘技術線圖表高度比例
  final double? indicatorRatio;

  /// 下方日期占用高度
  final double timelineFixed;

  /// 拖拉高度比例圖表的元件高度
  /// 此高度與主圖表綁定, 若主圖表沒有顯示, 則此值無效
  final double dragBarFixed;

  /// 拖拉最低偏移佔比
  final double minDragRadio;

  /// 拖拉最高偏移佔比
  final double maxDragRadio;

  /// 高度是否全為固定值
  bool isHeightFixed({
    required MainChartState mainChartState,
    required VolumeChartState volumeChartState,
    required IndicatorChartState indicatorChartState,
  }) {
    if (mainChartState != MainChartState.none && mainFixed == null) {
      return false;
    }
    if (volumeChartState != VolumeChartState.none && volumeFixed == null) {
      return false;
    }
    if (indicatorChartState != IndicatorChartState.none &&
        indicatorFixed == null) {
      return false;
    }
    return true;
  }

  /// 若高度全為固定值, 取得總高度
  /// 若不是全為固定值, 則回傳null
  double? getFixedHeight({
    required MainChartState mainChartState,
    required VolumeChartState volumeChartState,
    required IndicatorChartState indicatorChartState,
    required bool canDragBarShow,
    required bool dragBar,
  }) {
    if (!isHeightFixed(
      mainChartState: mainChartState,
      volumeChartState: volumeChartState,
      indicatorChartState: indicatorChartState,
    )) {
      return null;
    }
    final isMainEmpty = mainChartState == MainChartState.none;
    final isVolumeEmpty = volumeChartState == VolumeChartState.none;
    final isIndicatorEmpty = indicatorChartState == IndicatorChartState.none;

    double dragBarH;
    if (dragBar) {
      dragBarH = (isMainEmpty || (isVolumeEmpty && isIndicatorEmpty))
          ? 0.0
          : dragBarFixed;
    } else {
      dragBarH = 0;
    }
    if (dragBarH != 0 && !canDragBarShow) {
      dragBarH = 0;
    }

    final timelineH = (isMainEmpty && isVolumeEmpty && isIndicatorEmpty)
        ? 0.0
        : timelineFixed;

    final mainHeight = isMainEmpty ? 0 : mainFixed!;
    final volumeHeight = isVolumeEmpty ? 0 : volumeFixed!;
    final indicatorHeight = isIndicatorEmpty ? 0 : indicatorFixed!;
    return mainHeight + volumeHeight + indicatorHeight + timelineH + dragBarH;
  }

  const ChartHeightRatioSetting({
    this.mainFixed,
    this.mainRatio,
    this.volumeFixed,
    this.volumeRatio,
    this.indicatorFixed,
    this.indicatorRatio,
    this.dragBarFixed = 20,
    this.timelineFixed = 25,
    this.minDragRadio = 0.2,
    this.maxDragRadio = 0.8,
  }) : assert((mainFixed != null || mainRatio != null));

  /// 分配各個主題占用高度
  /// [mainChartOffsetY] - 主圖表的高度偏移增減
  ChartHeightCompute<double> computeChartHeight({
    required double totalHeight,
    required MainChartState mainChartState,
    required VolumeChartState volumeChartState,
    required IndicatorChartState indicatorChartState,
    required double dragOffset,
    required bool canDragBarShow,
    required bool dragBar,
  }) {
    final isMainEmpty = mainChartState == MainChartState.none;
    final isVolumeEmpty = volumeChartState == VolumeChartState.none;
    final isIndicatorEmpty = indicatorChartState == IndicatorChartState.none;

    double dragBarH;
    if (dragBar) {
      dragBarH = (isMainEmpty || (isVolumeEmpty && isIndicatorEmpty))
          ? 0.0
          : dragBarFixed;
    } else {
      dragBarH = 0;
    }
    if (dragBarH != 0 && !canDragBarShow) {
      dragBarH = 0;
    }

    final timelineH = (isMainEmpty && isVolumeEmpty && isIndicatorEmpty)
        ? 0.0
        : timelineFixed;

    final contentTotalHeight = totalHeight - timelineH - dragBarH;
    var remainTotalHeight = contentTotalHeight;

    double? mainHeight, volumeHeight, indicatorHeight;

    final isMainNeedRadio = !isMainEmpty && mainFixed == null;
    final isVolumeNeedRadio = !isVolumeEmpty && volumeFixed == null;
    final isIndicatorNeedRadio = !isIndicatorEmpty && indicatorFixed == null;

    if (isMainEmpty) {
      mainHeight = 0;
    } else if (!isMainNeedRadio) {
      remainTotalHeight -= mainFixed!;
      mainHeight = mainFixed!;
    }

    if (isVolumeEmpty) {
      volumeHeight = 0;
    } else if (!isVolumeNeedRadio) {
      remainTotalHeight -= volumeFixed!.toDouble();
      volumeHeight = volumeFixed!;
    }

    if (isIndicatorEmpty) {
      indicatorHeight = 0;
    } else if (!isIndicatorNeedRadio) {
      remainTotalHeight -= indicatorFixed!.toDouble();
      indicatorHeight = indicatorFixed!;
    }

    if (isMainNeedRadio) {
      mainHeight = remainTotalHeight * (mainRatio ?? 0);
    }
    if (isVolumeNeedRadio) {
      volumeHeight = remainTotalHeight * (volumeRatio ?? 0);
    }
    if (isIndicatorNeedRadio) {
      indicatorHeight = remainTotalHeight * (indicatorRatio ?? 0);
    }

    // 原本的main高度, 等下要與偏移後的高度做比對
    final oriMain = mainHeight!;

    // 最終main的偏移高度差距
    final double lastMainOffsetY;

    if (mainHeight != 0 && (volumeHeight != 0 || indicatorHeight != 0)) {
      mainHeight = mainHeight + dragOffset;

      final maxLimit = contentTotalHeight * maxDragRadio;
      final minLimit = contentTotalHeight * minDragRadio;

      if (mainHeight > maxLimit) {
        mainHeight = maxLimit;
      } else if (mainHeight < minLimit) {
        mainHeight = minLimit;
      }

      lastMainOffsetY = mainHeight - oriMain;
    } else {
      lastMainOffsetY = 0;
    }

    // 如果main有偏移高度差距, 則需要平均分配給買賣量圖表以及技術圖表
    if (lastMainOffsetY != 0) {
      if (volumeHeight != 0 && indicatorHeight != 0) {
        // 需要與技術線平均分攤
        volumeHeight = volumeHeight! - (lastMainOffsetY / 2);
        indicatorHeight = indicatorHeight! - (lastMainOffsetY / 2);
      } else if (volumeHeight != 0) {
        volumeHeight = volumeHeight! - lastMainOffsetY;
      } else if (indicatorHeight != 0) {
        indicatorHeight = indicatorHeight! - lastMainOffsetY;
      }
    }

    // print('高: $mainHeight, $volumeHeight, $indicatorHeight');

    return ChartHeightCompute<double>(
      main: mainHeight,
      volume: volumeHeight!,
      indicator: indicatorHeight!,
      timeline: timelineH,
      dragBar: dragBarH,
    );
  }
}

class ChartHeightCompute<T> {
  final T main;
  final T volume;
  final T indicator;
  final T timeline;
  final T dragBar;

  ChartHeightCompute({
    required this.main,
    required this.volume,
    required this.indicator,
    required this.timeline,
    required this.dragBar,
  });

  @override
  bool operator ==(Object other) {
    if (other is ChartHeightCompute) {
      return main == other.main &&
          volume == other.volume &&
          indicator == other.indicator &&
          timeline == other.timeline &&
          dragBar == other.dragBar;
    }
    return false;
  }
}
