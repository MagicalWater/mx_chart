/// 指數平滑異同移動平均線
class IndicatorMACD {
  final double dea;
  final double dif;
  final double macd;
  final double emaShort;
  final double emaLong;

  IndicatorMACD({
    required this.dea,
    required this.dif,
    required this.macd,
    required this.emaShort,
    required this.emaLong,
  });
}
