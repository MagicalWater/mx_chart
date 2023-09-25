import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mx_chart/mx_chart.dart';

import '../../repository/chart_repository.dart';

part 'k_chart_event.dart';

part 'k_chart_state.dart';

class KChartBloc extends Bloc<KChartEvent, KChartState> {
  KChartBloc(this.repository)
      : super(const KChartState(
          isLoading: false,
        )) {
    on<KChartInitEvent>(_onInitData);
    on<KChartUpdateLastEvent>(_onUpdateLast);
    on<KChartAddDataEvent>(_onAddData);
    on<KChartMainStateEvent>(_onChangedMainState);
    on<KChartVolumeChartStateEvent>(_onChangedVolumeState);
    on<KChartIndicatorChartStateEvent>(_onChangedIndicatorState);
    on<KChartMainIndicatorStateEvent>(_onChangedMainIndicatorState);
  }

  final ChartRepository repository;

  /// 初始化資料
  Future<void> _onInitData(
    KChartInitEvent event,
    Emitter<KChartState> emit,
  ) async {
    var datas = await repository.getData(event.index);
    print('資料筆數: ${datas.length}');
    emit(state.copyWith(datas: datas));
  }

  /// 更新最後一筆
  void _onUpdateLast(
    KChartUpdateLastEvent event,
    Emitter<KChartState> emit,
  ) {
    var lastData = state.datas.last;
    final open = lastData.close;
    final close = open + (Random().nextInt(100) - 50).toDouble();
    final maxOpenClose = max(open, close);
    final minOpenClose = min(open, close);
    final high = max(
      maxOpenClose,
      maxOpenClose + (Random().nextInt(100) - 50).toDouble(),
    );
    final low = max(
      minOpenClose,
      minOpenClose + (Random().nextInt(100) - 50).toDouble(),
    );
    final newData = KLineData(
      open: open,
      close: close,
      high: high,
      low: low,
      volume: lastData.volume + 10,
      amount: lastData.amount + 100,
      dateTime: lastData.dateTime.add(const Duration(days: 1)),
    );
    final newDatas = List<KLineData>.from(state.datas)
      ..removeLast()
      ..add(newData);
    newDatas.calculateAllIndicator();
    emit(state.copyWith(datas: newDatas));
  }

  /// 切換主視圖
  void _onChangedMainState(
    KChartMainStateEvent event,
    Emitter<KChartState> emit,
  ) {
    emit(state.copyWith(mainChartState: event.state));
  }

  /// 切換主視圖技術指標
  void _onChangedMainIndicatorState(
    KChartMainIndicatorStateEvent event,
    Emitter<KChartState> emit,
  ) {
    emit(state.copyWith(mainChartIndicatorState: event.state));
  }

  /// 切換成交量視圖
  void _onChangedVolumeState(
    KChartVolumeChartStateEvent event,
    Emitter<KChartState> emit,
  ) {
    emit(state.copyWith(volumeChartState: event.state));
  }

  /// 切換技術線視圖
  void _onChangedIndicatorState(
    KChartIndicatorChartStateEvent event,
    Emitter<KChartState> emit,
  ) {
    emit(state.copyWith(indicatorChartState: event.state));
  }

  void _onAddData(
    KChartAddDataEvent event,
    Emitter<KChartState> emit,
  ) {
    var lastData = state.datas.last;
    final open = lastData.close;
    final close = open + (Random().nextInt(100) - 50).toDouble();
    final maxOpenClose = max(open, close);
    final minOpenClose = min(open, close);
    final high = max(
      maxOpenClose,
      maxOpenClose + (Random().nextInt(100) - 50).toDouble(),
    );
    final low = max(
      minOpenClose,
      minOpenClose + (Random().nextInt(100) - 50).toDouble(),
    );
    final newData = KLineData(
      open: open,
      close: close,
      high: high,
      low: low,
      volume: lastData.volume + 10,
      amount: lastData.amount + 100,
      dateTime: lastData.dateTime.add(const Duration(days: 1)),
    );
    final newDatas = List<KLineData>.from(state.datas)..add(newData);
    newDatas.calculateAllIndicator();
    emit(state.copyWith(datas: newDatas));
  }
}
