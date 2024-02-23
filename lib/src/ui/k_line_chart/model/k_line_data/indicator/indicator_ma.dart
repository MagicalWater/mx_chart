/// 均線
class IndicatorMa {
  /// 各個週期的ma價
  final Map<int, double> ma = {};

  /// 隱式顯示的ma週期
  /// 不用於繪製, 只用來計算, 目前只作用在boll線上
  final List<int> implicitMa = [];
}