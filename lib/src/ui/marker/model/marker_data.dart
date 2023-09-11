import 'dart:ui';

import 'marker_position.dart';
import 'marker_type.dart';

/// 標記資料
class MarkerData {
  /// 標記編號
  final String id;

  /// 標記名稱
  final String name;

  /// 標記錨點
  final List<MarkerPosition> positions;

  /// 標記的類型
  final MarkerType type;

  /// 標記顏色
  final Color color;

  /// 標記線條粗細
  final double strokeWidth;

  /// 錨點半徑
  final double anchorPointRadius;

  /// 虛線設定(若不需要虛線則設置為空陣列即可)
  final List<double> dashArray;

  /// 建構子
  const MarkerData({
    required this.id,
    required this.name,
    required this.positions,
    required this.type,
    required this.color,
    required this.strokeWidth,
    required this.anchorPointRadius,
    this.dashArray = const [],
  });

  MarkerData copyWith({
    String? id,
    String? name,
    List<MarkerPosition>? positions,
    MarkerType? type,
    Color? color,
    double? strokeWidth,
    double? anchorPointRadius,
    List<double>? dashArray,
  }) {
    return MarkerData(
      id: id ?? this.id,
      name: name ?? this.name,
      positions: positions ?? this.positions,
      type: type ?? this.type,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      anchorPointRadius: anchorPointRadius ?? this.anchorPointRadius,
      dashArray: dashArray ?? this.dashArray,
    );
  }

  /// 將資料轉為 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'positions': positions.map((e) => e.toMap()),
      'type': type.name,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'anchorPointRadius': anchorPointRadius,
      'dashArray': dashArray,
    };
  }

  /// 將 Map 轉為資料
  factory MarkerData.fromMap(Map<String, dynamic> map) {
    return MarkerData(
      id: map['id'],
      name: map['name'],
      positions: (map['positions'] as List<dynamic>)
          .map((e) => MarkerPosition.fromMap(e as Map<String, dynamic>))
          .toList(),
      type: MarkerType.values.firstWhere((e) => e.name == map['type']),
      color: Color(map['color'] as int),
      strokeWidth: map['strokeWidth'],
      anchorPointRadius: map['anchorPointRadius'],
      dashArray: (map['dashArray'] as List<dynamic>).cast<double>(),
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
