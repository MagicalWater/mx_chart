import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_chart/src/ui/marker/model/model.dart';
import 'package:mx_chart/src/ui/marker/panel/stroke_width_panel.dart';
import 'package:popover/popover.dart';

import 'panel/color_panel.dart';
import 'panel/dash_path_panel.dart';
import 'panel/delete_panel.dart';

/// 標記的設定面板
class MarkerPanel extends StatefulWidget {
  final MarkerPath? marker;

  /// 設定值變更回調
  final ValueChanged<MarkerData?>? onChanged;

  final ValueChanged<Offset>? onDrag;

  const MarkerPanel({
    Key? key,
    required this.marker,
    this.onDrag,
    this.onChanged,
  }) : super(key: key);

  @override
  State<MarkerPanel> createState() => _MarkerPanelState();
}

class _MarkerPanelState extends State<MarkerPanel> {
  /// 設置偏移的位置
  Offset tempOffset = Offset.zero;

  /// 最終確定的offset
  Offset offset = Offset.zero;

  /// 當前是否拖拉中
  var isDrag = false;

  /// 子元件的size
  Size? contentSize;

  /// 此元件的尺寸約束
  BoxConstraints? constraints;

  /// 功能按鈕的尺寸
  final buttonSize = 30.0;

  /// 操控面板背景
  final panelBg = Colors.grey[850]!;

  /// 細碎icon顏色
  final iconColor = Colors.grey[500]!;

  @override
  Widget build(BuildContext context) {
    final defaultTheme = Theme.of(context);
    return Theme(
      data: defaultTheme.copyWith(
        iconTheme: defaultTheme.iconTheme.copyWith(
          color: iconColor,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          this.constraints = constraints.loosen();
          final tween = Tween(begin: 0.7, end: 1.0);
          return ConstrainedBox(
            constraints: constraints,
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: offset.dx,
                  top: offset.dy,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.fastOutSlowIn,
                  switchOutCurve: Curves.fastOutSlowIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: tween.animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: widget.marker == null
                      ? const SizedBox.shrink()
                      : _SizeGetter(
                          onGetSize: (size) {
                            if (contentSize != size) {
                              contentSize = size;
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                if (mounted) {
                                  _applyOffsetDefault();
                                  setState(() {});
                                }
                              });
                            }
                          },
                          child: Opacity(
                            opacity: contentSize == null ? 0 : 1,
                            child: _buildDraggable(context),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 讓此元件可以進行拖拉位移
  Widget _buildDraggable(BuildContext context) {
    final theme = Theme.of(context);
    final queryData = MediaQuery.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MediaQuery(
          data: queryData.copyWith(
            // 允許最小滑動
            gestureSettings: const DeviceGestureSettings(touchSlop: 0),
          ),
          child: Draggable(
            feedback: Theme(
              data: theme,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dragWidget(context, hide: false),
                  _buttonWidget(context),
                ],
              ),
            ),
            childWhenDragging: _dragWidget(context, hide: true),
            child: _dragWidget(context, hide: false),
            onDragStarted: () {
              tempOffset = offset;
              isDrag = true;
              setState(() {});
            },
            onDragUpdate: (details) {
              tempOffset =
                  tempOffset.translate(details.delta.dx, details.delta.dy);
            },
            onDragEnd: (details) {
              isDrag = false;
              _applyOffset(tempOffset);
              setState(() {});
            },
          ),
        ),
        Opacity(
          opacity: isDrag ? 0 : 1,
          child: _buttonWidget(context),
        ),
      ],
    );
  }

  Widget _dragWidget(BuildContext context, {bool hide = false}) {
    return Opacity(
      opacity: hide ? 0 : 1,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: panelBg,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(2),
          ),
        ),
        child: Icon(
          Icons.drag_indicator_rounded,
          size: buttonSize * 2 / 3,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buttonWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(2),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顏色設定
          _colorPanel(),

          const SizedBox(width: 5),

          // 線條寬度設定
          _strokePanel(),

          const SizedBox(width: 5),

          // 虛線設定
          _dashPanel(),

          const SizedBox(width: 5),

          // 刪除標記
          _deletePanel(),
        ],
      ),
    );
  }

  /// 刪除標記面板
  Widget _deletePanel() {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Builder(
        builder: (context) {
          return DeletePanel(
            onTap: () {
              widget.onChanged?.call(null);
            },
          );
        },
      ),
    );
  }

  /// 標記顏色設定面板
  Widget _colorPanel() {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Builder(
        builder: (context) {
          return ColorPanel(
            color: widget.marker?.data.color ?? Colors.black,
            onTap: () {
              showPopover(
                context: context,
                backgroundColor: panelBg,
                bodyBuilder: (context) => ColorPanelDetail(
                  itemWidth: 25,
                  itemHeight: 25,
                  space: 8,
                  colors: const [
                    Colors.orange,
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                    Colors.yellow,
                    Colors.purple,
                  ],
                  onChanged: (color) {
                    Navigator.of(context).pop();
                    if (widget.marker?.data != null &&
                        widget.marker!.data.color != color) {
                      final newData = widget.marker!.data.copyWith(
                        color: color,
                      );
                      widget.onChanged?.call(newData);
                      setState(() {});
                    }
                  },
                ),
                direction: PopoverDirection.top,
                arrowHeight: 0,
                arrowWidth: 0,
                radius: 2,
              );
            },
          );
        },
      ),
    );
  }

  /// 線條寬度設定面板
  Widget _strokePanel() {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Builder(
        builder: (context) {
          return StrokeWidthPanel(
            strokeWidth: widget.marker?.data.strokeWidth ?? 0,
            onTap: () {
              showPopover(
                context: context,
                backgroundColor: panelBg,
                bodyBuilder: (context) => StrokeWidthPanelDetail(
                  itemWidth: 40,
                  itemHeight: 20,
                  strokeWidths: const [1, 2, 3, 4],
                  onChanged: (strokeWidth) {
                    Navigator.of(context).pop();
                    if (widget.marker?.data != null) {
                      final newData = widget.marker!.data.copyWith(
                        strokeWidth: strokeWidth,
                      );
                      widget.onChanged?.call(newData);
                    }
                    setState(() {});
                  },
                ),
                direction: PopoverDirection.top,
                arrowHeight: 0,
                arrowWidth: 0,
                radius: 2,
              );
            },
          );
        },
      ),
    );
  }

  /// 虛線設定面板
  Widget _dashPanel() {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Builder(
        builder: (context) {
          List<double> dashArray;
          if (widget.marker?.data.dashArray.isEmpty ?? true) {
            dashArray = [];
          } else {
            dashArray = widget.marker!.data.dashArray;
          }
          return DashPathPanel(
            dashArray: dashArray,
            onTap: () {
              showPopover(
                context: context,
                backgroundColor: panelBg,
                bodyBuilder: (context) => DashPathPanelDetail(
                  itemWidth: 40,
                  itemHeight: 20,
                  dashArrays: const [
                    [2, 1],
                    [4, 2],
                    [6, 3],
                    [],
                  ],
                  onChanged: (dash) {
                    Navigator.of(context).pop();
                    if (widget.marker?.data != null) {
                      final newData = widget.marker!.data.copyWith(
                        dashArray: dash,
                      );
                      widget.onChanged?.call(newData);
                    }
                    setState(() {});
                  },
                ),
                direction: PopoverDirection.top,
                arrowHeight: 0,
                arrowWidth: 0,
                radius: 2,
              );
            },
          );
        },
      ),
    );
  }

  /// 將偏移量套用到元件上
  void _applyOffset(Offset offset) {
    if (constraints == null || contentSize == null) {
      return;
    }
    // 檢測offset是否需要修正(超出允許範圍需要)
    final rect = offset & contentSize!;

    double x, y;
    if (rect.left < 0) {
      x = 0;
    } else if (rect.right > constraints!.maxWidth) {
      x = constraints!.maxWidth - rect.width;
    } else {
      x = offset.dx;
    }

    if (rect.top < 0) {
      y = 0;
    } else if (rect.bottom > constraints!.maxHeight) {
      y = constraints!.maxHeight - rect.height;
    } else {
      y = offset.dy;
    }

    this.offset = Offset(x, y);
  }

  /// 將偏移量設為預設值
  /// 默認x在正中間, y距離下方20
  void _applyOffsetDefault() {
    if (constraints == null || contentSize == null) {
      return;
    }
    final x = (constraints!.maxWidth / 2) - (contentSize!.width / 2);
    final y = (constraints!.maxHeight) - (contentSize!.height) - 20;
    // print('默認x => $x => ${constraints} => ${contentSize}');

    offset = Offset(x, y);
  }
}

/// 由此元件取得child size
class _SizeGetter extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onGetSize;

  const _SizeGetter({
    Key? key,
    required this.onGetSize,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _SizeGetterBox(
      additionalConstraints: const BoxConstraints.tightFor(),
      onGetSize: onGetSize,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    if (renderObject is _SizeGetterBox) {
      renderObject.onGetSize = onGetSize;
    }
  }
}

class _SizeGetterBox extends RenderConstrainedBox {
  ValueChanged<Size> onGetSize;

  _SizeGetterBox({
    required super.additionalConstraints,
    required this.onGetSize,
  });

  @override
  void performLayout() {
    super.performLayout();
    onGetSize(size);
  }
}
