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

  /// 建構子
  const MarkerData({
    required this.id,
    required this.name,
    required this.positions,
    required this.type,
    required this.color,
    required this.strokeWidth,
  });

  /// 將資料轉為 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'positions': positions.map((e) => e.toMap()),
      'type': type.name,
      'color': color.value,
      'strokeWidth': strokeWidth,
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
    );
  }
}
