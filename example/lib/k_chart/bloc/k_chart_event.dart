part of 'k_chart_bloc.dart';

@immutable
abstract class KChartEvent {}

/// 初始化加載資料事件
class KChartInitEvent extends KChartEvent {}

/// 切換主視圖類型
class KChartMainStateEvent extends KChartEvent {
  final MainChartState state;

  KChartMainStateEvent({required this.state});
}

/// 切換主視圖技術線類型
class KChartMainIndicatorStateEvent extends KChartEvent {
  final MainChartIndicatorState state;

  KChartMainIndicatorStateEvent({required this.state});
}

/// 切換成交量視圖類型
class KChartVolumeChartStateEvent extends KChartEvent {
  final VolumeChartState state;

  KChartVolumeChartStateEvent({required this.state});
}

/// 切換技術線視圖類型
class KChartIndicatorChartStateEvent extends KChartEvent {
  final IndicatorChartState state;

  KChartIndicatorChartStateEvent({required this.state});
}

/// 更新最後一筆數據
class KChartUpdateLastEvent extends KChartEvent {
  KChartUpdateLastEvent();
}

/// 添加一筆數據
class KChartAddDataEvent extends KChartEvent {
  KChartAddDataEvent();
}
