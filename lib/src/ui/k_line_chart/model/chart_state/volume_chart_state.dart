enum VolumeChartState {
  volume,
  none,
}

extension VolumeChartStateValue on VolumeChartState {
  bool get isNone => this == VolumeChartState.none;

  bool get isVolume => this == VolumeChartState.volume;
}
