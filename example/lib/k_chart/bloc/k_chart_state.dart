part of 'k_chart_bloc.dart';

@immutable
class KChartState {
  final bool isLoading;
  final List<KLineData> datas;
  final MainChartState mainChartState;
  final MainChartIndicatorState mainChartIndicatorState;
  final VolumeChartState volumeChartState;
  final IndicatorChartState indicatorChartState;

  const KChartState({
    required this.isLoading,
    this.datas = const [],
    this.mainChartState = MainChartState.lineIndex,
    this.mainChartIndicatorState = MainChartIndicatorState.ma,
    this.volumeChartState = VolumeChartState.volume,
    this.indicatorChartState = IndicatorChartState.macd,
  });

  KChartState copyWith({
    bool? isLoading,
    List<KLineData>? datas,
    MainChartState? mainChartState,
    MainChartIndicatorState? mainChartIndicatorState,
    VolumeChartState? volumeChartState,
    IndicatorChartState? indicatorChartState,
  }) {
    return KChartState(
      isLoading: isLoading ?? this.isLoading,
      datas: datas ?? this.datas,
      mainChartState: mainChartState ?? this.mainChartState,
      mainChartIndicatorState:
          mainChartIndicatorState ?? this.mainChartIndicatorState,
      volumeChartState: volumeChartState ?? this.volumeChartState,
      indicatorChartState: indicatorChartState ?? this.indicatorChartState,
    );
  }
}
