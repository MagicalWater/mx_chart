/// 圖表尺寸設定
class ChartSizeSetting {
  /// 每筆資料占用的寬度
  final double dataWidth;

  /// 背景格線數量
  final int gridRows, gridColumns;

  /// 隔線粗細度
  final double gridLine;

  /// 由於圖表是否拖曳更改比例的, 此表示可以容許的最大最小網格高度
  /// 可為空, 代表一切皆可
  final double? minGridHeight, maxGridHeight;

  /// 長按時顯示的十字交叉線豎線寬度
  final double longPressVerticalLineWidth;

  /// 長按時顯示的交叉線橫線高度
  final double longPressHorizontalLineHeight;

  /// k線圖右邊的空格, 用於容納當圖表處於最新狀態時的數值指示
  final double rightSpace;

  /// 長按時, 對應y軸的數值
  final double longPressValue;

  /// 長按時, 數值邊框垂直/橫向padding
  final double longPressValueBorderVerticalPadding;
  final double longPressValueBorderHorizontalPadding;

  /// 長按時, 對應x軸的時間
  final double longPressTime;

  /// 長按時, 時間邊框垂直/橫向padding
  final double longPressTimeBorderVerticalPadding;
  final double longPressTimeBorderHorizontalPadding;

  /// 下方時間軸的文字大小
  final double bottomTimeText;

  /// 下方時間軸的線
  final double bottomTimeLine;

  /// 主圖表的拖曳bar線條高度
  final double dragBarLineHeight;

  /// 右方數值軸的分隔線寬度
  final double rightValueLine;

  const ChartSizeSetting({
    this.dataWidth = 8,
    this.gridRows = 3,
    this.gridColumns = 4,
    this.gridLine = 1,
    this.minGridHeight = 60,
    this.maxGridHeight = 100,
    this.rightSpace = 70,
    this.longPressVerticalLineWidth = 8,
    this.longPressHorizontalLineHeight = 0.2,
    this.longPressValue = 12,
    this.longPressValueBorderVerticalPadding = 4,
    this.longPressValueBorderHorizontalPadding = 12,
    this.longPressTime = 10,
    this.longPressTimeBorderVerticalPadding = 2,
    this.longPressTimeBorderHorizontalPadding = 12,
    this.bottomTimeText = 10,
    this.bottomTimeLine = 1,
    this.dragBarLineHeight = 1,
    this.rightValueLine = 1,
  });

  /// 取得應該設置的列數
  /// 因為原先[gridRows]的高度可能會超出[minGridHeight]~[maxGridHeight]的範圍
  /// 因此在此帶入高度, 回傳具體應該設置的rows數量
  int getRealRows(double height) {
    if (minGridHeight != null && maxGridHeight != null) {
      // 計算可以擁有的row數量上下限
      final maxRows = (height / minGridHeight!).floor();
      final minRows = (height / maxGridHeight!).ceil();

      // 有可能會出現maxRows比mixRows還小的情況
      // 例如 height / minGridHeight = 1.7, height / maxGridHeight = 1.4
      // 因此需要做取捨, 當出現這種情況, 則以minRows為主
      if (maxRows < minRows) {
        return minRows;
      }
      return gridRows.clamp(minRows, maxRows);
    } else if (minGridHeight != null) {
      final maxRows = (height / minGridHeight!).floor();
      return gridRows > maxRows ? maxRows : gridRows;
    } else if (maxGridHeight != null) {
      final minRows = (height / maxGridHeight!).ceil();
      return gridRows < minRows ? minRows : gridRows;
    } else {
      return gridRows;
    }
  }
}
