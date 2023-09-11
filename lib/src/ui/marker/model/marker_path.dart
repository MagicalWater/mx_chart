import 'package:flutter/material.dart';

import '../../marker/model/marker_data.dart';

class MarkerPath {
  MarkerData _data;

  MarkerData get data => _data;

  /// 路徑
  Path? path;

  /// 錨點路徑, index對應 [data.positions]
  List<Path> anchorPoint;

  MarkerPath({
    required MarkerData data,
  })  : _data = data,
        path = null,
        anchorPoint = [];

  void changeMarkerData(MarkerData data) {
    _data = data;
  }
}
