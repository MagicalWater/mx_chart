/// 標記圖案類型
enum MarkerType {
  /// 趨勢線
  /// 2個錨點
  trendLine,

  /// 延伸趨勢線
  /// 2個錨點
  extendTrendLine,

  /// 射線
  /// 2個錨點
  ray,

  /// 橫版交易(貫穿全圖表的價格線(但是不會顯示價格))
  /// 1個錨點
  horizontalTrade,

  /// 水平延伸
  /// 2個錨點
  horizontalExtend,

  /// 垂直延伸
  /// 2個錨點
  verticalExtend,

  /// 平行
  /// 3個錨點
  parallel,

  /// 價格線
  /// 1個錨點
  priceLine,

  /// 連波線
  /// 多個錨點
  waveLine,

  /// 矩形
  /// 2個錨點
  rectangle,

  /// 斐波那契
  /// 2個錨點
  fibonacci,
}