import 'package:mx_chart/mx_chart.dart';

export 'indicator/indicator.dart';

/// k線圖表資料
class KLineData {
  /// 開盤價
  final double open;

  /// 至高點
  final double high;

  /// 至低點
  final double low;

  /// 收盤價
  final double close;

  /// 成交量(手數)
  final double volume;

  /// 成交金額
  final double amount;

  /// 時間日期
  final DateTime dateTime;

  /// 技術指標資料
  final indicatorData = IndicatorData();

  KLineData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.amount,
    required this.dateTime,
  });

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (other is KLineData) {
      return open == other.open &&
          close == other.close &&
          low == other.low &&
          high == other.high &&
          volume == other.volume &&
          amount == other.amount &&
          dateTime == other.dateTime;
    }
    return false;
  }
}

class IndicatorData {
  /// 收盤價均線
  IndicatorMa? ma;

  /// boll線
  IndicatorBOLL? boll;

  /// 指數平滑異同移動平均線
  IndicatorMACD? macd;

  /// 相對強弱指標
  IndicatorRSI? rsi;

  /// 隨機指標
  IndicatorKDJ? kdj;

  /// 威廉指標(兼具超買超賣和強弱分界的指標)
  IndicatorWR? wr;
}

extension IndicatorCalculateExtension on List<KLineData> {
  /// 計算所有技術指標
  /// [maPeriods] - 收盤均線週期
  /// [bollPeriod] - boll線週期
  void calculateAllIndicator({
    IndicatorSetting indicatorSetting = const IndicatorSetting(),
  }) {
    calculateMA(periods: indicatorSetting.maSetting.periods);
    calculateBOLL(
      period: indicatorSetting.bollSetting.period,
      bandwidth: indicatorSetting.bollSetting.bandwidth,
    );
    calculateMACD(
      shortPeriod: indicatorSetting.macdSetting.shortPeriod,
      longPeriod: indicatorSetting.macdSetting.longPeriod,
      difPeriod: indicatorSetting.macdSetting.difPeriod,
    );
    calculateRSI(periods: indicatorSetting.rsiSetting.periods);
    calculateKDJ(
      period: indicatorSetting.kdjSetting.period,
      maPeriod1: indicatorSetting.kdjSetting.maPeriod1,
      maPeriod2: indicatorSetting.kdjSetting.maPeriod2,
    );
    calculateWR(periods: indicatorSetting.wrSetting.periods);
  }

  void calculateAllIndicatorAtLast({
    IndicatorSetting indicatorSetting = const IndicatorSetting(),
    required List<KLineData> newData,
  }) {
    calculateMaAtLast(
      periods: indicatorSetting.maSetting.periods,
      newData: newData,
    );
    calculateBollAtLast(
      period: indicatorSetting.bollSetting.period,
      bandwidth: indicatorSetting.bollSetting.bandwidth,
      newData: newData,
    );
    calculateMacdAtLast(
      shortPeriod: indicatorSetting.macdSetting.shortPeriod,
      longPeriod: indicatorSetting.macdSetting.longPeriod,
      difPeriod: indicatorSetting.macdSetting.difPeriod,
      newData: newData,
    );
    calculateRsiAtLast(
      periods: indicatorSetting.rsiSetting.periods,
      newData: newData,
    );
    calculateKdjAtLast(
      period: indicatorSetting.kdjSetting.period,
      maPeriod1: indicatorSetting.kdjSetting.maPeriod1,
      maPeriod2: indicatorSetting.kdjSetting.maPeriod2,
      newData: newData,
    );
    calculateWrAtLast(
      periods: indicatorSetting.wrSetting.periods,
      newData: newData,
    );
  }

  /// 計算收盤價均線
  void calculateMA({
    List<int> periods = const [5, 10, 20],
  }) {
    MaCalculator.calculateMA(periods: periods, datas: this);
  }

  void calculateMaAtLast({
    List<int> periods = const [5, 10, 20],
    required List<KLineData> newData,
  }) {
    MaCalculator.calculateMaAtLast(
      periods: periods,
      oriData: this,
      newData: newData,
    );
  }

  /// 計算boll線
  void calculateBOLL({
    int period = 20,
    int bandwidth = 2,
  }) {
    BollCalculator.calculateBOLL(
      period: period,
      bandwidth: bandwidth,
      datas: this,
    );
  }

  void calculateBollAtLast({
    int period = 20,
    int bandwidth = 2,
    required List<KLineData> newData,
  }) {
    BollCalculator.calculateBollAtLast(
      period: period,
      bandwidth: bandwidth,
      oriData: this,
      newData: newData,
    );
  }

  /// 計算指數平滑異同移動平均線
  void calculateMACD({
    int shortPeriod = 12,
    int longPeriod = 26,
    int difPeriod = 9,
  }) {
    MacdCalculator.calculateMACD(
      shortPeriod: shortPeriod,
      longPeriod: longPeriod,
      difPeriod: difPeriod,
      datas: this,
    );
  }

  void calculateMacdAtLast({
    int shortPeriod = 12,
    int longPeriod = 26,
    int difPeriod = 9,
    required List<KLineData> newData,
  }) {
    MacdCalculator.calculateMacdAtLast(
      shortPeriod: shortPeriod,
      longPeriod: longPeriod,
      difPeriod: difPeriod,
      oriData: this,
      newData: newData,
    );
  }

  /// 計算相對強弱指標
  void calculateRSI({
    List<int> periods = const [6, 12, 24],
  }) {
    RsiCalculator.calculateRSI(periods: periods, datas: this);
  }

  void calculateRsiAtLast({
    List<int> periods = const [6, 12, 24],
    required List<KLineData> newData,
  }) {
    RsiCalculator.calculateRsiAtLast(
      periods: periods,
      oriData: this,
      newData: newData,
    );
  }

  /// 計算隨機指標
  void calculateKDJ({
    int period = 9,
    int maPeriod1 = 3,
    int maPeriod2 = 3,
  }) {
    KdjCalculator.calculateKDJ(
      period: period,
      maPeriod1: maPeriod1,
      maPeriod2: maPeriod2,
      datas: this,
    );
  }

  void calculateKdjAtLast({
    int period = 9,
    int maPeriod1 = 3,
    int maPeriod2 = 3,
    required List<KLineData> newData,
  }) {
    KdjCalculator.calculateKDJAtLast(
      period: period,
      maPeriod1: maPeriod1,
      maPeriod2: maPeriod2,
      oriData: this,
      newData: newData,
    );
  }

  /// 計算威廉指標(兼具超買超賣和強弱分界的指標)
  void calculateWR({
    List<int> periods = const [6, 13],
  }) {
    WrCalculator.calculateWR(periods: periods, datas: this);
  }

  void calculateWrAtLast({
    List<int> periods = const [6, 13],
    required List<KLineData> newData,
  }) {
    WrCalculator.calculateWrAtLast(
      periods: periods,
      oriData: this,
      newData: newData,
    );
  }
}
