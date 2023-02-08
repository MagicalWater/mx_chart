import 'dart:ui';

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
  final double bottomTimeFixed;

  /// 拖拉高度比例圖表的元件高度
  /// 此高度與主圖表綁定, 若主圖表沒有顯示, 則此值無效
  final double scrollBarFixed;

  /// 主圖表的最低偏移佔比
  final double mainMinOffsetRatio;

  /// 主圖表的最高偏移佔比
  final double mainMaxOffsetRatio;

  /// 是否有設定主圖表高度
  bool get _isMainSetting => mainFixed != null || mainRatio != null;

  /// 是否有設定買賣圖表高度
  bool get _isVolumeSetting => volumeFixed != null || volumeRatio != null;

  /// 是否有設定技術圖表高度
  bool get _isIndicatorSetting =>
      indicatorFixed != null || indicatorRatio != null;

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

    final scrollBarH = (isMainEmpty || (isVolumeEmpty && isIndicatorEmpty))
        ? 0.0
        : scrollBarFixed;

    final bottomTimeH = (isMainEmpty && isVolumeEmpty && isIndicatorEmpty)
        ? 0.0
        : bottomTimeFixed;

    final mainHeight = isMainEmpty ? 0 : mainFixed!;
    final volumeHeight = isVolumeEmpty ? 0 : volumeFixed!;
    final indicatorHeight = isIndicatorEmpty ? 0 : indicatorFixed!;
    return mainHeight +
        volumeHeight +
        indicatorHeight +
        bottomTimeH +
        scrollBarH;
  }

  const ChartHeightRatioSetting({
    this.mainFixed,
    this.mainRatio,
    this.volumeFixed,
    this.volumeRatio,
    this.indicatorFixed,
    this.indicatorRatio,
    this.scrollBarFixed = 20,
    this.bottomTimeFixed = 25,
    this.mainMinOffsetRatio = 0.2,
    this.mainMaxOffsetRatio = 0.8,
  });

  /// 分配各個主題占用高度
  /// [mainChartOffsetY] - 主圖表的高度偏移增減
  ChartHeightCompute<double> computeChartHeight({
    required double totalHeight,
    required MainChartState mainChartState,
    required VolumeChartState volumeChartState,
    required IndicatorChartState indicatorChartState,
    required double mainChartHeightOffset,
  }) {
    final isMainEmpty = mainChartState == MainChartState.none;
    final isVolumeEmpty = volumeChartState == VolumeChartState.none;
    final isIndicatorEmpty = indicatorChartState == IndicatorChartState.none;

    final scrollBarH = (isMainEmpty || (isVolumeEmpty && isIndicatorEmpty))
        ? 0.0
        : scrollBarFixed;

    final bottomTimeH = (isMainEmpty && isVolumeEmpty && isIndicatorEmpty)
        ? 0.0
        : bottomTimeFixed;

    final remainTotalHeight = totalHeight - bottomTimeH - scrollBarH;

    double? mainHeight, volumeHeight, indicatorHeight;
    if (mainChartState == MainChartState.none) {
      mainHeight = 0;
    } else if (_isMainSetting) {
      mainHeight =
          mainFixed ?? (mainRatio! * remainTotalHeight).floorToDouble();
    }

    if (isVolumeEmpty) {
      volumeHeight = 0;
    } else if (_isVolumeSetting) {
      volumeHeight =
          volumeFixed ?? (volumeRatio! * remainTotalHeight).floorToDouble();
    }

    if (isIndicatorEmpty) {
      indicatorHeight = 0;
    } else if (_isIndicatorSetting) {
      indicatorHeight = indicatorFixed ??
          (indicatorRatio! * remainTotalHeight).floorToDouble();
    }

    mainHeight ??=
        remainTotalHeight - (volumeHeight ?? 0) - (indicatorHeight ?? 0);
    volumeHeight ??= remainTotalHeight - mainHeight - (indicatorHeight ?? 0);
    indicatorHeight ??= remainTotalHeight - mainHeight - volumeHeight;

    // 原本的main高度, 等下要與偏移後的高度做比對
    final oriMain = mainHeight;

    // 最終main的偏移高度差距
    final double lastMainOffsetY;

    if (mainHeight != 0 && (volumeHeight != 0 || indicatorHeight != 0)) {
      mainHeight += mainChartHeightOffset;

      final maxLimit = remainTotalHeight * mainMaxOffsetRatio;
      final minLimit = remainTotalHeight * mainMinOffsetRatio;

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
        volumeHeight -= (lastMainOffsetY / 2);
        indicatorHeight -= (lastMainOffsetY / 2);
      } else if (volumeHeight != 0) {
        volumeHeight -= lastMainOffsetY;
      } else if (indicatorHeight != 0) {
        indicatorHeight -= lastMainOffsetY;
      }
    }

    // print('高: $mainHeight, $volumeHeight, $indicatorHeight');

    return ChartHeightCompute<double>(
      main: mainHeight,
      volume: volumeHeight,
      indicator: indicatorHeight,
      bottomTime: bottomTimeH,
      scrollBar: scrollBarH,
    );
  }
}

class ChartHeightCompute<T> {
  final T main;
  final T volume;
  final T indicator;
  final T bottomTime;
  final T scrollBar;

  ChartHeightCompute({
    required this.main,
    required this.volume,
    required this.indicator,
    required this.bottomTime,
    required this.scrollBar,
  });
}

extension HeightToRect on ChartHeightCompute<double> {
  /// 將高轉換為Rect
  ChartHeightCompute<Rect> toRect(Size size) {
    final mainRect = Rect.fromLTRB(0, 0, size.width, main);
    final scrollBarRect = Rect.fromLTWH(0, main, size.width, scrollBar);
    final volumeRect =
        Rect.fromLTWH(0, scrollBarRect.bottom, size.width, volume);
    final indicatorRect =
        Rect.fromLTWH(0, volumeRect.bottom, size.width, indicator);
    final bottomTimeRect =
        Rect.fromLTWH(0, indicatorRect.bottom, size.width, bottomTime);
    return ChartHeightCompute<Rect>(
      main: mainRect,
      volume: volumeRect,
      indicator: indicatorRect,
      bottomTime: bottomTimeRect,
      scrollBar: scrollBarRect,
    );
  }
}
