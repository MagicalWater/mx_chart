class KdjSetting {
  /// rsv的計算週期
  final int period;

  /// k值計算週期
  final int maPeriod1;

  /// d值計算週期
  final int maPeriod2;

  const KdjSetting({
    this.period = 9,
    this.maPeriod1 = 3,
    this.maPeriod2 = 3,
  });
}
