import 'dart:async';

import 'package:flutter/gestures.dart';

import '../chart_gesture.dart';
import '../gestures/gesture.dart';

/// 手勢歸類分發
mixin GestureDistributionMixin on ChartGesture
    implements TapGesture, DragGesture, LongPressGesture, ScaleGesture {
  /// 目前正在起作用的觸摸
  final activePointer = <int, List<PointerPosition>>{};

  /// 觸摸到變成長按的檢測時間
  final _longPressDetect = const Duration(milliseconds: 500);

  /// 當拖拉超過此距離, 則結束長按倒數
  final _cancelLongPressTimerDistance = 5;

  /// 長按倒數
  Timer? _longPressTimer;

  /// 初始拖拉offset
  late Offset _initDragPoint;

  /// 初始scale distance
  late double _initScaleDistance;

  /// 長按狀態是否可被拖拉繼承
  /// 是 -> 抬起時不標示為長按抬起
  ///      有新手勢在按下並拖拉, 且無其他正在點擊中的手勢, 將會繼承長按的資訊
  bool keepLongPressWhenTouchUp = true;

  /// 當前是否處於繼承長按狀態
  bool _isNowInheritLongPress = false;

  /// 繼承長按狀態的觸摸時間
  DateTime? _inheritLongPressStartTime;

  /// 延遲加入繼承長按的時間
  Duration inheritLongPressDelay = const Duration(milliseconds: 100);

  /// 取得當前縮放的全局焦點
  PointerPosition get _currentScaleFocalPoint {
    final pointers = activePointer.values.toList();
    final point1 = pointers[0].last;
    final point2 = pointers[1].last;
    return PointerPosition(
      global: (point1.global + point2.global) / 2,
      local: (point1.local + point2.local) / 2,
    );
  }

  /// 取得當前兩指距離
  double get _currentTouchDistance {
    final pointers = activePointer.values.toList();
    final point1 = pointers[0].last;
    final point2 = pointers[1].last;
    return (point2.global - point1.global).distance;
  }

  /// 取得當前縮放的倍數
  double get _currentScale {
    final pointers = activePointer.values.toList();
    final point1 = pointers[0].last;
    final point2 = pointers[1].last;
    return (point2.global - point1.global).distance / _initScaleDistance;
  }

  @override
  TouchStatus getTouchPointerStatus(int pointer) {
    if (activePointer.keys.contains(pointer)) {
      if (isDrag) {
        return TouchStatus.drag;
      } else if (isScale) {
        return TouchStatus.scale;
      } else if (isLongPress) {
        return TouchStatus.longPress;
      } else {
        return TouchStatus.none;
        // 正常狀態不會在此
        // if (kDebugMode) {
        //   print('GestureDistributionMixin: 觸摸狀態異常');
        // }
        // throw 'GestureDistributionMixin: 觸摸狀態異常';
      }
    } else {
      return TouchStatus.none;
    }
  }

  @override
  void onTouchDown(int pointer, DragStartDetails details) {
    if (isDrag) {
      // 正在拖拉中, 變更為開始縮放
      activePointer[pointer] = [PointerPosition.fromDragStart(details)];

      isDrag = false;
      isScale = true;

      _initScaleDistance = _currentTouchDistance;

      _cancelLongPressTimer();

      final scalePosition = _currentScaleFocalPoint;
      onScaleStart(ScaleStartDetails(
        focalPoint: scalePosition.global,
        localFocalPoint: scalePosition.local,
        pointerCount: 2,
      ));

      _sendPointerEvent(pointer, PointerStatus.down);
    } else if (isScale || isLongPress) {
      // 正在縮放/長按中, 禁止其餘觸摸
      if (keepLongPressWhenTouchUp && activePointer.isEmpty) {
        // 表示有需要繼承的長按手勢
        _isNowInheritLongPress = true;
        activePointer[pointer] = [PointerPosition.fromDragStart(details)];
        _initDragPoint = details.globalPosition;
        _inheritLongPressStartTime = DateTime.now();

        _sendPointerEvent(pointer, PointerStatus.down);
      }
      return;
    } else {
      // 目前無任何手勢, 啟動拖拉
      activePointer[pointer] = [PointerPosition.fromDragStart(details)];
      isDrag = true;

      _initDragPoint = details.globalPosition;

      // 啟動長按倒數
      if (!isLongPressDisable) {
        _startLongPressTimer();
      }

      onDragStart(details);
      _sendPointerEvent(pointer, PointerStatus.down);
    }
  }

  @override
  void onTouchUpdate(int pointer, DragUpdateDetails details) {
    if (!activePointer.containsKey(pointer)) {
      return;
    }
    if (isDrag) {
      // 當前為拖拉狀態, 則發出拖拉更新
      activePointer[pointer]!.add(PointerPosition.fromDragUpdate(details));

      // 檢測是否需要取消長按倒數
      if (_longPressTimer != null) {
        final needCancel = (details.globalPosition - _initDragPoint).distance >
            _cancelLongPressTimerDistance;
        if (needCancel) {
          _cancelLongPressTimer();
        }
      }

      onDragUpdate(details);
      _sendPointerEvent(pointer, PointerStatus.move);
    } else if (isLongPress) {
      // 當前為長按狀態, 發出長按拖拉更新
      if (_isNowInheritLongPress &&
          DateTime.now().difference(_inheritLongPressStartTime!) <
              inheritLongPressDelay) {
        return;
      }

      final prePointer = activePointer[pointer]!.last;
      activePointer[pointer]!.add(PointerPosition.fromDragUpdate(details));
      onLongPressMoveUpdate(LongPressMoveUpdateDetails(
        globalPosition: details.globalPosition,
        localPosition: details.localPosition,
        offsetFromOrigin: details.globalPosition - prePointer.global,
        localOffsetFromOrigin: details.localPosition - prePointer.local,
      ));
      _sendPointerEvent(pointer, PointerStatus.move);
    } else if (isScale) {
      // 當前為縮放狀態, 發出縮放更新
      final preScalePosition = _currentScaleFocalPoint;
      activePointer[pointer]!.add(PointerPosition.fromDragUpdate(details));
      final scalePosition = _currentScaleFocalPoint;
      final scale = _currentScale;
      onScaleUpdate(ScaleUpdateDetails(
        focalPoint: scalePosition.global,
        localFocalPoint: scalePosition.local,
        scale: scale,
        verticalScale: scale,
        horizontalScale: scale,
        pointerCount: 2,
        focalPointDelta: scalePosition.global - preScalePosition.global,
      ));
      _sendPointerEvent(pointer, PointerStatus.move);
    }
  }

  @override
  void onTouchUp(int pointer, DragEndDetails details) {
    if (!activePointer.containsKey(pointer)) {
      return;
    }
    if (isDrag) {
      isDrag = false;
      _cancelLongPressTimer();
      onDragEnd(details);
    } else if (isLongPress) {
      final position = activePointer[pointer]!.last;

      // 檢查此長按是否為繼承的行為
      if (_isNowInheritLongPress) {
        // 檢查時間
        final duration = DateTime.now().difference(_inheritLongPressStartTime!);
        // 時間是否符合取消範圍
        final isDurationCancel = duration < _longPressDetect;

        // 檢查距離
        final distance = (position.global - _initDragPoint).distance;
        final isDistanceCancel = distance < _cancelLongPressTimerDistance;

        if (isDurationCancel && isDistanceCancel) {
          _isNowInheritLongPress = false;
          isLongPress = false;
          onLongPressEnd(LongPressEndDetails(
            globalPosition: position.global,
            localPosition: position.local,
            velocity: details.velocity,
          ));
        }
      } else {
        if (!keepLongPressWhenTouchUp) {
          isLongPress = false;
          onLongPressEnd(LongPressEndDetails(
            globalPosition: position.global,
            localPosition: position.local,
            velocity: details.velocity,
          ));
        }
      }
    } else if (isScale) {
      isScale = false;
      isDrag = true;
      onScaleEnd(ScaleEndDetails(
        velocity: details.velocity,
        pointerCount: 2,
      ));
    }
    _sendPointerEvent(pointer, PointerStatus.up);
    _removePointerListener(pointer);
    activePointer.remove(pointer);
  }

  /// 發送pointer的資訊更新通知事件
  void _sendPointerEvent(int pointer, PointerStatus pointerStatus) {
    final history = activePointer[pointer];
    if (history == null || history.isEmpty) {
      return;
    }

    final firstEvent = history.first;
    final lastEvent = history.last;

    final info = PointerInfo(
      touchStatus: getTouchPointerStatus(pointer),
      pointerStatus: pointerStatus,
      startPosition: firstEvent,
      lastPosition: lastEvent,
      dragOffset: lastEvent.global - firstEvent.global,
    );

    pointerListeners[pointer]?.forEach((element) {
      element(info);
    });
  }

  /// 取消觸摸(當觸摸後沒有任何位移, 則會呼叫此)
  @override
  void onTouchCancel(int pointer) {
    if (!activePointer.containsKey(pointer)) {
      return;
    }
    if (isDrag) {
      isDrag = false;
      _cancelLongPressTimer();
      onDragCancel();
    } else if (isLongPress) {
      // 檢查此長按是否為繼承的行為
      if (_isNowInheritLongPress) {
        _isNowInheritLongPress = false;
        isLongPress = false;
        onLongPressCancel();
      } else {
        if (!keepLongPressWhenTouchUp) {
          isLongPress = false;
          onLongPressCancel();
        }
      }
    } else if (isScale) {
      isScale = false;
      onScaleCancel();
    }
    _sendPointerEvent(pointer, PointerStatus.up);
    _removePointerListener(pointer);
    activePointer.remove(pointer);
  }

  /// 設置長案是否禁用
  @override
  void setLongPress(bool enable) {
    if (enable) {
      isLongPressDisable = false;
    } else {
      isLongPress = false;
      isLongPressDisable = true;
      _isNowInheritLongPress = false;
      onLongPressCancel();

      // 因為長案被禁止了, 所以若當前有長案或者保留長案的設定都要清除
      _cancelLongPressTimer();
    }
  }

  void _startLongPressTimer() {
    _cancelLongPressTimer();

    _longPressTimer = Timer(_longPressDetect, () {
      // print('長按激活');
      _cancelLongPressTimer();
      final entrys = activePointer.entries;
      if (entrys.isEmpty) {
        // print('長按為空, 取消');
        return;
      }
      final position = entrys.first.value.last;
      isDrag = false;
      isLongPress = true;
      onLongPressStart(LongPressStartDetails(
        globalPosition: position.global,
        localPosition: position.local,
      ));
    });
  }

  void _cancelLongPressTimer() {
    if (_longPressTimer != null && _longPressTimer!.isActive) {
      _longPressTimer!.cancel();
    }
    _longPressTimer = null;
  }

  /// 移除某個pointer全部的監聽
  void _removePointerListener(int pointer) {
    pointerListeners.remove(pointer);
  }
}

class PointerPosition {
  final Offset global;
  final Offset local;

  PointerPosition({required this.global, required this.local});

  PointerPosition.fromDragStart(DragStartDetails details)
      : global = details.globalPosition,
        local = details.localPosition;

  PointerPosition.fromDragUpdate(DragUpdateDetails details)
      : global = details.globalPosition,
        local = details.localPosition;

  @override
  String toString() {
    return 'PointerPosition(global: $global, local: $local)';
  }
}
