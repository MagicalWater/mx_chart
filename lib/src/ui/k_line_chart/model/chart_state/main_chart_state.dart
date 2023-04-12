/// 主圖表的顯示狀態
enum MainChartState {
  /// 蠟燭圖
  kLine,

  /// 收盤價折線圖
  lineIndex,

  /// 不顯示主題表
  none,
}

extension MainChartStateValue on MainChartState {
  bool get isNone => this == MainChartState.none;

  bool get isKLine => this == MainChartState.kLine;

  bool get isLineIndex => this == MainChartState.lineIndex;
}
