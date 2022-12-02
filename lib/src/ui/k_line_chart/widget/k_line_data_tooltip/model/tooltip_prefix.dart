/// 前綴文字
class TooltipPrefix {
  final String time;
  final String open;
  final String high;
  final String low;
  final String close;
  final String changeValue;
  final String changeRate;
  final String volume;

  const TooltipPrefix({
    this.time = 'time',
    this.open = 'open',
    this.high = 'high',
    this.low = 'low',
    this.close = 'close',
    this.changeValue = 'change',
    this.changeRate = 'changeRate',
    this.volume = 'volume',
  });
}