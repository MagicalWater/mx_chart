import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'multi_touch_drag.dart';
import 'multi_touch_gesture_recognizer.dart';

export 'touch_pointer_move.dart';

/// 多點觸控手勢
class MultiTouchGestureRecognizer extends MultiDragGestureRecognizer {
  final void Function(int pointer, DragStartDetails details)? onTouchDown;
  final void Function(int pointer)? onTouchCancel;

  /// 用於取得裝載此按鍵處理的RawGestureDector
  /// 目的是將globalPostion轉化為localPosition
  final GlobalKey<RawGestureDetectorState>? transformPositionKey;

  /// 決定某個點擊是否允許移動更新
  /// 回傳[GestureDisposition.rejected]代表直接否決[pointer]的觸摸
  /// 回傳[GestureDisposition.accepted]代表直接通過[pointer]的觸摸
  ///
  /// 若回傳null代表尚未決定, 此方法仍會在觸摸有更新時持續呼叫
  /// 直至回傳了結果, 或者點擊事件被其餘觸摸元件擷取
  final GestureDisposition? Function(TouchPointerMove move)? isAllowPointerMove;

  MultiTouchGestureRecognizer({
    required this.transformPositionKey,
    Object? debugOwner,
    Set<PointerDeviceKind>? supportedDevices,
    this.onTouchDown,
    void Function(int pointer, DragUpdateDetails details)? onTouchUpdate,
    void Function(int pointer, DragEndDetails details)? onTouchUp,
    this.isAllowPointerMove,
    this.onTouchCancel,
  }) : super(
          debugOwner: debugOwner,
          supportedDevices: supportedDevices,
        ) {
    onStart = (offset) {
      final eventEntry = _pointerEvent.entries
          .firstWhere((element) => element.value.position == offset);
      final pointer = eventEntry.key;

      // 自暫存移除事件
      _pointerEvent.remove(pointer);

      return MultiTouchDrag(
        pointer: pointer,
        onUpdate: (details) {
          // 由於MultiDragGestureRecognizer的拖拉訊息缺少local
          // 因此獲取到的位置將會是global的, 在此需要進行轉化
          final renderBox = transformPositionKey?.currentContext
              ?.findRenderObject() as RenderBox?;
          final Offset localPosition;
          if (renderBox != null) {
            localPosition = renderBox.globalToLocal(details.globalPosition);
          } else {
            localPosition = details.localPosition;
          }
          onTouchUpdate?.call(
            pointer,
            DragUpdateDetails(
              sourceTimeStamp: details.sourceTimeStamp,
              delta: details.delta,
              primaryDelta: details.primaryDelta,
              globalPosition: details.globalPosition,
              localPosition: localPosition,
            ),
          );
        },
        onEnd: (details) {
          onTouchUp?.call(pointer, details);
        },
        onCancel: () {
          onTouchCancel?.call(pointer);
        },
      );
    };
  }

  static GestureRecognizerFactory factory({
    required GlobalKey<RawGestureDetectorState>? transformPositionKey,
    void Function(int pointer, DragStartDetails details)? onTouchStart,
    void Function(int pointer, DragUpdateDetails details)? onTouchUpdate,
    void Function(int pointer, DragEndDetails details)? onTouchEnd,
    void Function(int pointer)? onTouchCancel,
    GestureDisposition? Function(TouchPointerMove move)? isAllowPointerMove,
  }) {
    return GestureRecognizerFactoryWithHandlers<MultiTouchGestureRecognizer>(
      () => MultiTouchGestureRecognizer(
        transformPositionKey: transformPositionKey,
        onTouchDown: onTouchStart,
        onTouchUpdate: onTouchUpdate,
        onTouchUp: onTouchEnd,
        onTouchCancel: onTouchCancel,
        isAllowPointerMove: isAllowPointerMove,
      ),
      (MultiTouchGestureRecognizer instance) {},
    );
  }

  final _pointerEvent = <int, PointerDownEvent>{};

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    _pointerEvent[event.pointer] = event;

    // print('按下囉: ${event.position}, ${event.localPosition}');

    onTouchDown?.call(
      event.pointer,
      DragStartDetails(
        sourceTimeStamp: event.timeStamp,
        globalPosition: event.position,
        localPosition: event.localPosition,
        kind: event.kind,
      ),
    );

    return _MultiTouchState(
      initialPosition: event.position,
      kind: event.kind,
      deviceGestureSettings: gestureSettings,
      isAllowMove: (pendingDelta) {
        if (isAllowPointerMove == null) {
          return GestureDisposition.accepted;
        } else {
          return isAllowPointerMove!(TouchPointerMove(
            pointer: event.pointer,
            pendingDelta: pendingDelta,
            kind: event.kind,
            gestureSettings: gestureSettings,
          ));
        }
      },
      onCancelWithNoDrag: () {
        _pointerEvent.remove(event.pointer);
        onTouchCancel?.call(event.pointer);
      },
    );
  }

  @override
  String get debugDescription => 'multi touch';
}

class _MultiTouchState extends MultiDragPointerState {
  /// 是否已初始化Drag
  var isDragInit = false;

  /// 尚未拖拉之前就取消了觸摸, 那麼觸摸取消手勢就會從此發出
  final VoidCallback onCancelWithNoDrag;

  final GestureDisposition? Function(Offset pendingDelta) isAllowMove;

  _MultiTouchState({
    required Offset initialPosition,
    required PointerDeviceKind kind,
    DeviceGestureSettings? deviceGestureSettings,
    required this.onCancelWithNoDrag,
    required this.isAllowMove,
  }) : super(initialPosition, kind, deviceGestureSettings);

  @override
  void checkForResolutionAfterMove() {
    assert(pendingDelta != null);

    // 檢查是否允許此觸摸
    final isAllow = isAllowMove.call(pendingDelta!);
    if (isAllow != null) {
      resolve(isAllow);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    starter(initialPosition);
    isDragInit = true;
  }

  @override
  void dispose() {
    if (!isDragInit) {
      onCancelWithNoDrag();
    }
    super.dispose();
  }
}
