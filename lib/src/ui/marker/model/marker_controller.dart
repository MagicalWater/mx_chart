part of '../chart_marker.dart';

class MarkerController {
  _ChartMarkerState? _bind;

  bool get hasClient => _bind != null;

  /// 當前正在編輯中的marker id
  String? get currentEditId => _bind?.currentEditId;

  /// 當前的marker mode
  MarkerMode? get currentMode => _bind?.currentMode;

  MarkerType? get currentMarkerTypeIfAdd => _bind?.currentMarkerTypeIfAdd;

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
            '[MarkerController.setMarkerMode]錯誤: KLineChartController尚未綁定至KLineChart上, 忽略此次請求');
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
  bool setMarkers(
    List<MarkerData> markers, {
    bool animated = true,
    Curve? curve,
    Duration? duration,
  }) {
    if (_bind == null) {
      if (kDebugMode) {
        print(
            '[MarkerController.setMarkers]錯誤: KLineChartController尚未綁定至KLineChart上, 忽略此次請求');
      }
      return false;
    }
    _bind!.setMarkers(
      markers,
      animated: animated,
      curve: curve,
      duration: duration,
    );
    return true;
  }

  void dispose() {
    _bind = null;
  }
}
