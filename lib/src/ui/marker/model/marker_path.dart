import 'package:flutter/material.dart';

import '../../marker/model/marker_data.dart';

class MarkerPath {
  final MarkerData data;
  final Path? path;
  final Path? path2;

  MarkerPath({
    required this.data,
    required this.path,
    this.path2,
  });
}
