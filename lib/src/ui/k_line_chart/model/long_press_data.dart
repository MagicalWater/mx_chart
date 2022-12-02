import 'model.dart';

/// 長按的資料
class LongPressData {
  /// 長按的資料index
  final int index;

  /// 長按的k線資料
  final KLineData data;

  /// 長按的前一筆資料
  final KLineData? prevData;

  /// 長按的資料是否處於元件左側
  final bool isLongPressAtLeft;

  LongPressData({
    required this.index,
    required this.data,
    required this.prevData,
    required this.isLongPressAtLeft,
  });

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (other is LongPressData) {
      return index == other.index &&
          data == other.data &&
          prevData == other.prevData &&
          isLongPressAtLeft == other.isLongPressAtLeft;
    }
    return false;
  }
}
