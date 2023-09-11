part of '../chart_marker.dart';

class MarkerController {
  _ChartMarkerState? _bind;

  /// 設定Marker模式
  /// [markerMode] - Marker模式
  /// [editId] - 編輯的marker id, 若設定的mode是[MarkerMode.edit]則需要帶入
  /// [markerTypeIfAdd] - 設定當模式為新增時, 默認新增的類型, 可空, 因為原本就有預設類型
  void setMarkerMode(
    MarkerMode markerMode, {
    String? editId,
    MarkerType? markerTypeIfAdd,
  }) {
    if (_bind == null) {
      if (kDebugMode) {
        print(
            '[MarkerController.setMarkerMode]錯誤: KLineChartController尚未綁定至KLineChart上, 忽略此次請求');
      }
    }
    _bind?.setMarkerMode(
      markerMode,
      editId: editId,
      markerTypeIfAdd: markerTypeIfAdd,
    );
  }

  /// 設定marker資料列表
  /// [markers] - marker資料列表
  void setMarkers(List<MarkerData> markers) {
    if (_bind == null) {
      if (kDebugMode) {
        print(
            '[MarkerController.setMarkers]錯誤: KLineChartController尚未綁定至KLineChart上, 忽略此次請求');
      }
    }
    _bind?.setMarkers(markers);
  }

  void dispose() {
    _bind = null;
  }
}
