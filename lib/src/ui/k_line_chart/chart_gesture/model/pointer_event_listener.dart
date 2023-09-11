import 'dart:ui';

import '../chart_gesture.dart';
import '../impl/gesture_distribution_mixin.dart';

/// 監聽某個pointer的所有活動以及狀態
typedef PointerEventListener = void Function(PointerInfo event);

/// 觸摸資訊
class PointerInfo {
  /// 觸摸狀態(拖拉中/縮放中/長按中/無)
  final TouchStatus touchStatus;

  /// 手指狀態(按下/移動/抬起)
  final PointerStatus pointerStatus;

  /// 起始觸摸位置
  final PointerPosition startPosition;

  /// 最終觸摸位置
  final PointerPosition lastPosition;

  /// 總位移距離
  final Offset? dragOffset;

  PointerInfo({
    required this.touchStatus,
    required this.pointerStatus,
    required this.startPosition,
    required this.lastPosition,
    this.dragOffset,
  });
}

