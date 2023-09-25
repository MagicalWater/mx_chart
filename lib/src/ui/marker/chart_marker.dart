import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mx_chart/src/ui/k_line_chart/chart_gesture/chart_gesture.dart';
import 'package:mx_chart/src/ui/k_line_chart/widget/touch_gesture_dector/touch_gesture_dector.dart';
import 'package:mx_chart/src/ui/marker/panel.dart';

import '../k_line_chart/model/model.dart';
import 'painter.dart';

export 'model/model.dart';
export 'painter.dart';
export 'reversible_path.dart';
export 'thickness_path.dart';

part 'model/marker_controller.dart';

class ChartMarker extends StatefulWidget {
  final double width;
  final double height;
  final List<MarkerData>? initMarkers;
  final ChartPainterValueInfo painterValueInfo;
  final PricePosition position;
  final Duration dataPeriod;
  final String Function(num price) priceFormatter;

  final ChartGesture chartGesture;

  /// 初始模式
  final MarkerMode initMode;

  final String? initEditId;

  /// 當新增路徑時預設的type
  final MarkerType initMarkerTypeIfAdd;

  /// Marker處於新增模式時的進度
  /// [type] - 當前新增的類型
  /// [point] - 當前已經新增的點位數量
  /// [totalPoint] - 總共需要新增的點位數量
  final void Function(MarkerType type, int point, int totalPoint)?
      onMarkerAddProgress;

  /// 當Marker mode有變更時的回調
  final void Function(MarkerMode mode)? onModeChanged;

  /// 當有Marker新增時的回調
  /// 有新增時會回調此方法, 同時回調 onMarkerUpdate
  final void Function(MarkerData marker)? onMarkerAdd;

  /// 當有Marker刪除時的回調
  /// 有刪除時會回調此方法, 同時回調 onMarkerUpdate
  final void Function(MarkerData marker)? onMarkerRemove;

  /// 當Marker列表有更新時回調
  final void Function(List<MarkerData> markers)? onMarkerUpdate;

  /// 控制器
  final MarkerController? controller;

  const ChartMarker({
    Key? key,
    required this.width,
    required this.height,
    required this.chartGesture,
    this.initMarkers,
    required this.painterValueInfo,
    required this.position,
    required this.dataPeriod,
    required this.priceFormatter,
    required this.initMode,
    required this.initMarkerTypeIfAdd,
    this.controller,
    this.onMarkerAdd,
    this.onMarkerAddProgress,
    this.onMarkerRemove,
    this.onMarkerUpdate,
    this.onModeChanged,
    this.initEditId,
  }) : super(key: key);

  @override
  State<ChartMarker> createState() => _ChartMarkerState();
}

class _ChartMarkerState extends State<ChartMarker> {
  late List<MarkerPath> currentPaths;

  final markerOffset = <MarkerData, Offset>{};

  /// 當前正在編輯中的marker id
  String? currentEditId;

  /// 需要新建立的marker資料
  MarkerPath? newCreateData;

  /// 最後一次觸摸的位置
  Offset? lastTouchLocalPosition;

  /// 舊的編輯目標資料
  MarkerPath? oldEditData;

  /// 如果拖移的是錨點, 則是拖移第幾個錨點
  int? moveAnchorIndex;

  /// 針對當前的編輯目標資料的拖移點
  var moveTarget = _MoveTarget.none;

  /// 當前的marker mode
  late MarkerMode currentMode;

  late MarkerType currentMarkerTypeIfAdd;

  /// 構建marker時是否使用動畫
  int animatedKeyIndex = 0;

  /// 構建marker的動畫差值器
  Curve animatedCurve = Curves.easeOut;

  /// 構建marker的動畫持續時間
  Duration animatedDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    currentPaths =
        (widget.initMarkers ?? []).map((e) => MarkerPath(data: e)).toList();
    currentMode = widget.initMode;
    currentMarkerTypeIfAdd = widget.initMarkerTypeIfAdd;

    if (currentMode == MarkerMode.add) {
      widget.onMarkerAddProgress?.call(
        currentMarkerTypeIfAdd,
        0,
        currentMarkerTypeIfAdd.needPoint,
      );
    }

    currentEditId = widget.initEditId;
    widget.controller?._bind = this;

    // 針對模式決定是否禁止外層K線的長按功能
    switch (currentMode) {
      case MarkerMode.view:
        widget.chartGesture.setLongPress(true);
        break;
      default:
        widget.chartGesture.setLongPress(false);
        break;
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChartMarker oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._bind = null;
      widget.controller?._bind = this;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          TouchGestureDetector(
            onTouchStart: onTouchStart,
            onTouchUpdate: onTouchUpdate,
            onTouchEnd: (pointer, details) => onTouchEnd(pointer),
            // 取消跟抬起相同處理
            onTouchCancel: onTouchEnd,
            isAllowPointerMove: (move) {
              switch (currentMode) {
                case MarkerMode.add:
                  return GestureDisposition.accepted;
                case MarkerMode.edit:
                  return GestureDisposition.accepted;
                case MarkerMode.view:
                  return GestureDisposition.rejected;
                case MarkerMode.editableView:
                  return GestureDisposition.rejected;
              }
            },
            child: RepaintBoundary(
              child: AnimatedSwitcher(
                duration: animatedDuration,
                switchInCurve: animatedCurve,
                switchOutCurve: animatedCurve,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: CustomPaint(
                  key: ValueKey(animatedKeyIndex),
                  size: Size(widget.width, widget.height),
                  painter: ChartMarkerPainter(
                    markers: [
                      ...currentPaths,
                      if (newCreateData != null) newCreateData!,
                    ],
                    painterValueInfo: widget.painterValueInfo,
                    pricePosition: widget.position,
                    period: widget.dataPeriod,
                    priceFormatter: widget.priceFormatter,
                    markerMode: currentMode,
                    markerOffset: markerOffset,
                    editId: currentEditId,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: MarkerPanel(
              marker: newCreateData ?? oldEditData,
              onDrag: (offset) {},
              onChanged: (marker) {
                if (marker == null) {
                  // 刪除標記
                  final value = newCreateData ?? oldEditData!;
                  currentPaths.remove(value);

                  // 退出編輯模式
                  currentEditId = null;
                  oldEditData = null;
                  currentMode = MarkerMode.editableView;
                  widget.onModeChanged?.call(currentMode);
                  widget.onMarkerRemove?.call(value.data);
                } else {
                  if (newCreateData != null) {
                    newCreateData!.changeMarkerData(marker);
                  } else {
                    oldEditData!.changeMarkerData(marker);
                  }
                }
                widget.onMarkerUpdate
                    ?.call(currentPaths.map((e) => e.data).toList());
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 將畫布上的某個點轉化為實際的座標位置
  MarkerPosition _realPointToMarkerPosition(Offset point) {
    final painterInfo = widget.painterValueInfo;
    final displayX = painterInfo.realXToDisplayX(point.dx);
    late double xRate;
    final dataIndex = painterInfo.displayXToDataIndex(
      displayX,
      percentCallback: (percent) {
        xRate = percent;
      },
    );

    DateTime markerTime;
    if (dataIndex >= painterInfo.datas.length) {
      // index已經超出範圍, 使用預估的方式取得marker的點位時間
      // 不考慮沒有資料, 因為運行至此代表有資料
      final lastData = painterInfo.datas.last;
      final overIndex = dataIndex - (painterInfo.datas.length - 1);
      markerTime = lastData.dateTime.add(widget.dataPeriod * overIndex);
    } else if (dataIndex < 0) {
      final overIndex = dataIndex.abs();
      // index已經超出範圍, 使用預估的方式取得marker的點位時間
      // 不考慮沒有資料, 因為運行至此代表有資料
      final firstData = painterInfo.datas.first;

      markerTime = firstData.dateTime.subtract(widget.dataPeriod * overIndex);
    } else {
      markerTime = painterInfo.datas[dataIndex].dateTime;
    }

    final price = widget.position.realYToPrice(point.dy);

    return MarkerPosition(
      dateTime: markerTime,
      xRate: xRate,
      price: price,
    );
  }

  /// 將path的偏移套用
  void _applyOffset(MarkerPath markerPath) {
    final painterInfo = widget.painterValueInfo;

    // 將位移的Offset轉成實際的點
    final allPosition = markerPath.data.positions;
    final newPositions = <MarkerPosition>[];
    for (var element in allPosition) {
      // 套用位移
      final offset = markerOffset[markerPath.data] ?? Offset.zero;

      // 先取得displayX
      final displayX = painterInfo.timeToDisplayX(element.dateTime,
              percent: element.xRate) ??
          painterInfo.estimateTimeToDisplayX(
            element.dateTime,
            period: widget.dataPeriod,
            percent: element.xRate,
          );

      // 接著取得displayY
      final realY = widget.position.priceToY(element.price);

      if (displayX == null) {
        // 發生找不到位置, 則停止套用
        return;
      }
      final newDisplayX = displayX + offset.dx;
      final newRealY = realY + offset.dy;

      late double xRate;

      // 再將display轉回實際的點
      final newDataIndex = painterInfo.displayXToDataIndex(
        newDisplayX,
        percentCallback: (percent) {
          xRate = percent;
        },
      );

      DateTime markerTime;
      if (newDataIndex >= painterInfo.datas.length) {
        // index已經超出範圍, 使用預估的方式取得marker的點位時間
        // 不考慮沒有資料, 因為運行至此代表有資料
        final lastData = painterInfo.datas.last;
        final overIndex = newDataIndex - (painterInfo.datas.length - 1);
        markerTime = lastData.dateTime.add(widget.dataPeriod * overIndex);
      } else if (newDataIndex < 0) {
        final overIndex = newDataIndex.abs();
        // index已經超出範圍, 使用預估的方式取得marker的點位時間
        // 不考慮沒有資料, 因為運行至此代表有資料
        final firstData = painterInfo.datas.first;
        markerTime = firstData.dateTime.subtract(widget.dataPeriod * overIndex);
      } else {
        markerTime = painterInfo.datas[newDataIndex].dateTime;
      }

      final newPrice = widget.position.realYToPrice(newRealY);

      final position = MarkerPosition(
        dateTime: markerTime,
        xRate: xRate,
        price: newPrice,
      );

      newPositions.add(position);
    }

    // 替換position
    allPosition.replaceRange(
      0,
      allPosition.length,
      newPositions,
    );

    markerOffset.clear();
  }

  void onTouchStart(int pointer, DragStartDetails details) {
    lastTouchLocalPosition = details.localPosition;
    switch (currentMode) {
      case MarkerMode.add:
        if (newCreateData != null) {
          currentEditId = newCreateData!.data.id;
          oldEditData = null;

          // 確認是點在錨點或者路徑上
          // 錨點則拖移目標是錨點
          // 路徑則是整個拖移
          final anchorPointIndex = newCreateData!.anchorPoint
              .indexWhere((element) => element.contains(details.localPosition));
          if (anchorPointIndex != -1) {
            // 點在錨點上
            moveTarget = _MoveTarget.anchorPoint;
            moveAnchorIndex = anchorPointIndex;
          } else if (newCreateData!.path?.contains(details.localPosition) ??
              false) {
            // 點在路徑上
            moveTarget = _MoveTarget.path;
            moveAnchorIndex = null;
          } else {
            // 都不是就不處理
            moveTarget = _MoveTarget.none;
            moveAnchorIndex = null;
          }
        } else {
          newCreateData = MarkerPath(
            data: MarkerData(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: currentMarkerTypeIfAdd,
              name: DateTime.now().millisecondsSinceEpoch.toString(),
              positions: [],
              color: Colors.yellow,
              strokeWidth: 1,
              anchorPointRadius: 5,
            ),
          );
          currentEditId = newCreateData!.data.id;
          moveTarget = _MoveTarget.none;
          oldEditData = null;
        }
        setState(() {});

        break;
      case MarkerMode.edit:
        // 取得編輯目標

        final anchorIndex = oldEditData!.anchorPoint
            .indexWhere((element) => element.contains(details.localPosition));

        final pathContain =
            oldEditData!.path?.contains(details.localPosition) ?? false;

        if (anchorIndex != -1 || pathContain) {
          // 觸摸編輯目標, 可以對編輯目標進行拖移

          if (anchorIndex != -1) {
            moveTarget = _MoveTarget.anchorPoint;
            moveAnchorIndex = anchorIndex;
          } else {
            moveTarget = _MoveTarget.path;
            moveAnchorIndex = null;
          }
        } else {
          moveTarget = _MoveTarget.none;
        }
        // print('選中編輯目標: $currentEditId($oldEditData), 拖移目標: $moveTarget');
        break;
      case MarkerMode.view:
        return;
      case MarkerMode.editableView:
        currentEditId = null;
        oldEditData = null;
        moveTarget = _MoveTarget.none;

        // 監聽此pointer的結束事件
        widget.chartGesture.addPointerListener(pointer, (event) {
          if (event.pointerStatus == PointerStatus.up) {
            // print(
            //     '${event.pointerStatus} => ${event.touchStatus} => ${event.dragOffset}');
            // 只有在抬起時才處理
            // 是否點擊到marker
            final pathIndex = currentPaths.lastIndexWhere((element) =>
                element.path?.contains(details.localPosition) ?? false);
            if (pathIndex != -1) {
              final editTarget = currentPaths[pathIndex];
              currentEditId = editTarget.data.id;
              oldEditData = editTarget;
              currentPaths.removeAt(pathIndex);
              currentPaths.add(editTarget);

              // 轉換成編輯模式
              currentMode = MarkerMode.edit;
              widget.onModeChanged?.call(currentMode);
              setState(() {});
            }
          }
        });
        return;
    }
  }

  void onTouchUpdate(int pointer, DragUpdateDetails details) {
    lastTouchLocalPosition = details.localPosition;
    // 當有拖移目標時才處理
    switch (moveTarget) {
      case _MoveTarget.none:
        break;
      case _MoveTarget.path:
        // 需要整體移動, 更改為偏移
        if (newCreateData != null) {
          final initOffset = markerOffset[newCreateData!.data] ?? Offset.zero;
          markerOffset[newCreateData!.data] =
              initOffset.translate(details.delta.dx, details.delta.dy);
          setState(() {});
        } else if (oldEditData != null) {
          final initOffset = markerOffset[oldEditData!.data] ?? Offset.zero;
          markerOffset[oldEditData!.data] =
              initOffset.translate(details.delta.dx, details.delta.dy);
          setState(() {});
        }
        break;
      case _MoveTarget.anchorPoint:
        if (moveAnchorIndex != null) {
          // 取得新的位置
          final newPosition = _realPointToMarkerPosition(details.localPosition);
          // 取出要移動的錨點
          if (newCreateData != null) {
            newCreateData!.data.positions.replaceRange(
              moveAnchorIndex!,
              moveAnchorIndex! + 1,
              [newPosition],
            );
            setState(() {});
          } else if (oldEditData != null) {
            oldEditData!.data.positions.replaceRange(
              moveAnchorIndex!,
              moveAnchorIndex! + 1,
              [newPosition],
            );
            setState(() {});
          }
        }
        break;
    }
  }

  void onTouchEnd(int pointer) {
    switch (currentMode) {
      case MarkerMode.add:
        switch (moveTarget) {
          case _MoveTarget.anchorPoint:
            break;
          case _MoveTarget.path:
            _applyOffset(newCreateData!);
            setState(() {});
            break;
          case _MoveTarget.none:
            // 需要添加錨點
            final newPosition =
                _realPointToMarkerPosition(lastTouchLocalPosition!);
            newCreateData!.data.positions.add(newPosition);

            // 檢查錨點是否已足夠, 若以足夠代表創建完成
            if (newCreateData!.data.type.needPoint ==
                newCreateData!.data.positions.length) {
              // 新增完成, 切換為編輯模式
              currentMode = MarkerMode.edit;
              currentEditId = newCreateData!.data.id;
              oldEditData = newCreateData;
              currentPaths.add(newCreateData!);
              widget.onMarkerAddProgress?.call(
                newCreateData!.data.type,
                newCreateData!.data.positions.length,
                newCreateData!.data.type.needPoint,
              );
              widget.onModeChanged?.call(currentMode);
              widget.onMarkerAdd?.call(newCreateData!.data);
              widget.onMarkerUpdate
                  ?.call(currentPaths.map((e) => e.data).toList());
              newCreateData = null;
            } else {
              widget.onMarkerAddProgress?.call(
                newCreateData!.data.type,
                newCreateData!.data.positions.length,
                newCreateData!.data.type.needPoint,
              );
            }

            setState(() {});
            break;
        }
        break;
      case MarkerMode.edit:
        if (oldEditData != null) {
          switch (moveTarget) {
            case _MoveTarget.anchorPoint:
              // 移動錨點
              final newPosition =
                  _realPointToMarkerPosition(lastTouchLocalPosition!);
              oldEditData!.data.positions.replaceRange(
                moveAnchorIndex!,
                moveAnchorIndex! + 1,
                [newPosition],
              );
              widget.onMarkerUpdate
                  ?.call(currentPaths.map((e) => e.data).toList());
              setState(() {});
              break;
            case _MoveTarget.path:
              _applyOffset(oldEditData!);
              widget.onMarkerUpdate
                  ?.call(currentPaths.map((e) => e.data).toList());
              setState(() {});
              break;
            case _MoveTarget.none:
              // 檢測彈起的位置是否處於任何可編輯物件內
              // 若是的話將編輯目標轉移
              // 否則退出編輯模式
              final inPathIndex = currentPaths.lastIndexWhere((element) =>
                  element.path?.contains(lastTouchLocalPosition!) ?? false);

              // print('是否點在路徑上: $inPath');
              if (inPathIndex != -1) {
                // 設定編輯目標
                final editTarget = currentPaths[inPathIndex];
                currentEditId = editTarget.data.id;
                oldEditData = editTarget;
                currentPaths.removeAt(inPathIndex);
                currentPaths.add(editTarget);

                // 轉換成編輯模式
                currentMode = MarkerMode.edit;
                widget.onModeChanged?.call(currentMode);
                setState(() {});
              } else {
                // 退出編輯模式
                currentEditId = null;
                oldEditData = null;
                currentMode = MarkerMode.editableView;
                widget.onModeChanged?.call(currentMode);
                setState(() {});
              }
              break;
          }
        }
        break;
      case MarkerMode.view:
        break;
      case MarkerMode.editableView:
        break;
    }
  }

  /// 設定Marker模式
  /// [editId] - 編輯的marker id, 若設定的mode是[MarkerMode.edit]則需要帶入
  /// [markerTypeIfAdd] - 設定當模式為新增時, 默認新增的類型, 可空, 因為原本就有預設類型
  void setMarkerMode(
    MarkerMode mode, {
    String? editId,
    MarkerType? markerTypeIfAdd,
  }) {
    if (markerTypeIfAdd != null) {
      currentMarkerTypeIfAdd = markerTypeIfAdd;
    }

    switch (mode) {
      case MarkerMode.add:
        // 新增模式, 要禁止外層K線的長按效果
        widget.chartGesture.setLongPress(false);

        // 若當前的模式不是新增模式, 則轉換成新增模式
        if (currentMode != MarkerMode.add) {
          // 設定模式
          currentMode = MarkerMode.add;
          // 清除舊的編輯資料
          oldEditData = null;
          // 清除舊的新增資料
          newCreateData = null;
          // 清除舊的編輯id
          currentEditId = null;
          // 清除舊的marker偏移
          markerOffset.clear();
          // 清除位移目標
          moveTarget = _MoveTarget.none;

          // 將新增狀態回傳給外部
          widget.onMarkerAddProgress?.call(
            currentMarkerTypeIfAdd,
            0,
            currentMarkerTypeIfAdd.needPoint,
          );

          setState(() {});
        }
        break;
      case MarkerMode.edit:
        if (editId == null) {
          if (kDebugMode) {
            print('[ChartMarker] - 編輯模式必須帶入編輯的marker id');
          }
          throw '[ChartMarker] - 編輯模式必須帶入編輯的marker id';
        }

        // 尋找編輯目標
        final findDataIndex =
            currentPaths.lastIndexWhere((element) => element.data.id == editId);

        if (findDataIndex == -1) {
          if (kDebugMode) {
            print('[ChartMarker] - 編輯模式找不到對應的marker id');
          }
          throw '[ChartMarker] - 編輯模式找不到對應的marker id';
        }

        // 編輯模式, 要禁止外層K線的長按效果
        widget.chartGesture.setLongPress(false);

        // 設定模式
        currentMode = MarkerMode.edit;
        // 清除舊的編輯資料
        oldEditData = currentPaths.removeAt(findDataIndex);

        currentPaths.add(oldEditData!);

        // 清除舊的新增資料
        newCreateData = null;
        // 清除舊的編輯id
        currentEditId = editId;
        // 清除舊的marker偏移
        markerOffset.clear();
        // 清除位移目標
        moveTarget = _MoveTarget.none;
        setState(() {});
        break;
      case MarkerMode.view:
        // 瀏覽模式, 允許外層K線長按
        widget.chartGesture.setLongPress(true);

        // 進入瀏覽模式
        currentMode = MarkerMode.view;
        // 清除舊的編輯資料
        oldEditData = null;
        // 清除舊的新增資料
        newCreateData = null;
        // 清除舊的編輯id
        currentEditId = null;
        // 清除舊的marker偏移
        markerOffset.clear();
        // 清除位移目標
        moveTarget = _MoveTarget.none;
        setState(() {});
        break;
      case MarkerMode.editableView:
        // 瀏覽模式, 禁止外層K線長按
        widget.chartGesture.setLongPress(false);

        // 進入可編輯瀏覽模式
        currentMode = MarkerMode.editableView;
        // 清除舊的編輯資料
        oldEditData = null;
        // 清除舊的新增資料
        newCreateData = null;
        // 清除舊的編輯id
        currentEditId = null;
        // 清除舊的marker偏移
        markerOffset.clear();
        // 清除位移目標
        moveTarget = _MoveTarget.none;
        setState(() {});
        break;
    }

    widget.onModeChanged?.call(currentMode);
  }

  /// 設定marker資料列表
  /// [markers] - marker資料列表
  void setMarkers(
    List<MarkerData> markers, {
    bool animated = true,
    Curve? curve,
    Duration? duration,
  }) {
    // 只有在瀏覽模式或者可編輯瀏覽模式才可以設定marker
    if (currentMode == MarkerMode.view ||
        currentMode == MarkerMode.editableView) {
      currentPaths = markers.map((e) => MarkerPath(data: e)).toList();
      if (animated) {
        animatedKeyIndex++;
      }
      if (curve != null) {
        animatedCurve = curve;
      }
      if (duration != null) {
        animatedDuration = duration;
      }
      setState(() {});
    } else {
      if (kDebugMode) {
        print('[ChartMarker] - 只有在瀏覽模式或者可編輯瀏覽模式才可以設定marker');
      }
      throw '[ChartMarker] - 只有在瀏覽模式或者可編輯瀏覽模式才可以設定marker';
    }
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }
}

enum _MoveTarget {
  anchorPoint,
  path,
  none,
}

// extension _MoveTargetExtension on _MoveTarget {
//   bool get isAnchorPoint => this == _MoveTarget.anchorPoint;
//
//   bool get isPath => this == _MoveTarget.path;
//
//   bool get isNone => this == _MoveTarget.none;
// }
