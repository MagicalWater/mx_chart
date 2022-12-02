import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

/// 決定child放置位置的佈局
/// [PositionLayout]自身會將寬高拉至允許的最大值
/// [child]則會按照給定的x,y位置以及對齊方式進行佈局
class PositionLayout extends SingleChildRenderObjectWidget {
  /// 固定x
  final double? xFixed;

  /// 固定y
  final double? yFixed;

  /// x比例
  final double? xRatio;

  /// y比例
  final double? yRatio;

  /// [child]的錨點
  final Alignment anchorPoint;

  /// 超出邊界是否調整位置
  final bool outBoundAdjust;

  const PositionLayout({
    Key? key,
    required Widget child,
    this.xFixed,
    this.yFixed,
    this.xRatio,
    this.yRatio,
    this.anchorPoint = Alignment.center,
    this.outBoundAdjust = false,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PositionRenderBox(
      xFixed: xFixed,
      xRatio: xRatio,
      yFixed: yFixed,
      yRatio: yRatio,
      anchorPoint: anchorPoint,
      outBoundAdjust: outBoundAdjust,
      child: null,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as PositionRenderBox)
      ..xFixed = xFixed
      ..xRatio = xRatio
      ..yFixed = yFixed
      ..yRatio = yRatio
      ..anchorPoint = anchorPoint
      ..outBoundAdjust = outBoundAdjust;
    renderObject.markNeedsLayout();
    super.updateRenderObject(context, renderObject);
  }
}

class PositionRenderBox extends RenderShiftedBox {
  /// 固定x
  double? xFixed;

  /// 固定y
  double? yFixed;

  /// x比例
  double? xRatio;

  /// y比例
  double? yRatio;

  /// [child]的錨點
  Alignment anchorPoint;

  /// 超出邊界是否調整位置
  bool outBoundAdjust;

  PositionRenderBox({
    required this.xFixed,
    required this.yFixed,
    required this.xRatio,
    required this.yRatio,
    this.anchorPoint = Alignment.center,
    this.outBoundAdjust = false,
    RenderBox? child,
  }) : super(child);

  @override
  void performLayout() {
    final childConstraint = constraints.loosen();
    child!.layout(childConstraint, parentUsesSize: true);
    final childSize = child!.size;

    final biggestSize = constraints.biggest;
    final x = xFixed ?? biggestSize.width * (xRatio ?? 0);
    final y = yFixed ?? biggestSize.height * (yRatio ?? 0);

    // 算出錨點應該對準child的位置
    final anchorOffset = anchorPoint.alongSize(childSize);

    // 算出child的位置
    var childOffset = Offset(x, y) - anchorOffset;

    // 若child超出邊界, 檢查是否需要調整
    if (outBoundAdjust) {
      // 檢查x軸是否超出邊界
      if (childOffset.dx < 0) {
        childOffset = Offset(0, childOffset.dy);
      } else if (childOffset.dx + childSize.width > biggestSize.width) {
        childOffset = Offset(
          biggestSize.width - childSize.width,
          childOffset.dy,
        );
      }

      // 檢查y軸是否超出邊界
      if (childOffset.dy < 0) {
        childOffset = Offset(childOffset.dx, 0);
      } else if (childOffset.dy + childSize.height > biggestSize.height) {
        childOffset = Offset(
          childOffset.dx,
          biggestSize.height - childSize.height,
        );
      }
    }

    final childData = child!.parentData as BoxParentData;
    childData.offset = childOffset;
    size = biggestSize;
  }
}
