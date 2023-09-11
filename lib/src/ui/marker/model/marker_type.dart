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

  /// 3連波線
  /// 多個錨點
  waveLine3,

  /// 矩形
  /// 2個錨點
  rectangle,

  /// 斐波那契
  /// 2個錨點
  fibonacci,
}

extension MarkerTypePoint on MarkerType {
  int get needPoint {
    switch (this) {
      case MarkerType.trendLine:
        return 2;
      case MarkerType.extendTrendLine:
        return 2;
      case MarkerType.ray:
        return 2;
      case MarkerType.horizontalTrade:
        return 1;
      case MarkerType.horizontalExtend:
        return 2;
      case MarkerType.verticalExtend:
        return 2;
      case MarkerType.parallel:
        return 3;
      case MarkerType.priceLine:
        return 1;
      case MarkerType.waveLine3:
        return 3;
      case MarkerType.rectangle:
        return 2;
      case MarkerType.fibonacci:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
