enum IndicatorChartState {
  macd,
  rsi,
  wr,
  kdj,
  none,
}

extension IndicatorChartStateValue on IndicatorChartState {
  bool get isNone => this == IndicatorChartState.none;

  bool get isMacd => this == IndicatorChartState.macd;

  bool get isRsi => this == IndicatorChartState.rsi;

  bool get isWr => this == IndicatorChartState.wr;

  bool get isKdj => this == IndicatorChartState.kdj;
}
