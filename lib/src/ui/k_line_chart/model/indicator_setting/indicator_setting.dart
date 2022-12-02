import 'setting/setting.dart';

export 'setting/setting.dart';

/// 技術線設定
class IndicatorSetting {
  final MaSetting maSetting;
  final BollSetting bollSetting;
  final KdjSetting kdjSetting;
  final MacdSetting macdSetting;
  final RsiSetting rsiSetting;
  final WrSetting wrSetting;

  const IndicatorSetting({
    this.maSetting = const MaSetting(),
    this.bollSetting = const BollSetting(),
    this.kdjSetting = const KdjSetting(),
    this.macdSetting = const MacdSetting(),
    this.rsiSetting = const RsiSetting(),
    this.wrSetting = const WrSetting(),
  });

  IndicatorSetting copyWith({
    MaSetting? maSetting,
    BollSetting? bollSetting,
    KdjSetting? kdjSetting,
    MacdSetting? macdSetting,
    RsiSetting? rsiSetting,
    WrSetting? wrSetting,
  }) {
    return IndicatorSetting(
      maSetting: maSetting ?? this.maSetting,
      bollSetting: bollSetting ?? this.bollSetting,
      kdjSetting: kdjSetting ?? this.kdjSetting,
      macdSetting: macdSetting ?? this.macdSetting,
      rsiSetting: rsiSetting ?? this.rsiSetting,
      wrSetting: wrSetting ?? this.wrSetting,
    );
  }
}
