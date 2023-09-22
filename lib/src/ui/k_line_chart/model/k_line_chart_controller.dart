part of '../view/k_line_chart.dart';

class KLineChartController {
  _KLineChartState? _bind;

  bool get hasClient => _bind != null;

  /// 滾動回起點
  /// [animated] - 是否使用動畫滾動
  Future<bool> scroll1ToRight({bool animated = true}) async {
    if (_bind == null) {
      if (kDebugMode) {
        print(
            '[KLineChartController.scroll1ToRight]錯誤: KLineChartController尚未綁定至KLineChart上, 忽略此次請求');
      }
      return false;
    }
    return _bind!.scrollToRight(animated: animated).then((value) => true);
  }

  /// 設定Marker模式
  /// [markerMode] - Marker模式
  /// [editId] - 編輯的marker id, 若設定的mode是[MarkerMode.edit]則需要帶入
  /// [markerTypeIfAdd] - 設定當模式為新增時, 默認新增的類型, 可空, 因為原本就有預設類型
  bool setMarkerMode(
    MarkerMode markerMode, {
    String? editId,
    MarkerType? markerTypeIfAdd,
  }) {
    if (_bind == null) {
      if (kDebugMode) {
        print(
            '[KLineChartController.setMarkerMode]錯誤: KLineChartController尚未綁定至KLineChart上, 忽略此次請求');
      }
      return false;
    }
    _bind!.setMarkerMode(
      markerMode,
      editId: editId,
      markerTypeIfAdd: markerTypeIfAdd,
    );
    return true;
  }

  /// 設定marker資料列表
  /// [markers] - marker資料列表
  bool setMarkers(List<MarkerData> markers) {
    if (_bind == null) {
      if (kDebugMode) {
        print(
            '[KLineChartController.setMarkers]錯誤: KLineChartController尚未綁定至KLineChart上, 忽略此次請求');
      }
      return false;
    }
    _bind!.setMarkers(markers);
    return true;
  }

  void dispose() {
    _bind = null;
  }
}
