part of 'line_indicator.dart';

class _LinePainter extends CustomPainter {
  /// 元件大小, 整個粒子運動空間
  final double start, end;

  double? lineSize;
  final Axis direction;
  final double? maxLength;
  final EdgeInsets padding;
  final Alignment alignment;
  final DashStyle? dashStyle;

  BoxPainter painter;

  List<_PlacePainter> placePainters;

  _LinePainter({
    required this.start,
    required this.end,
    required this.padding,
    required this.direction,
    required this.alignment,
    required this.painter,
    required this.placePainters,
    this.dashStyle,
    this.lineSize,
    this.maxLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var bgPlace = placePainters.where((element) => !element.placeUp).toList();
    var fgPlace = placePainters.where((element) => element.placeUp).toList();

    // print('背景: ${bgPlace.length}, 前景: ${fgPlace.length}');

    switch (direction) {
      case Axis.horizontal:
        lineSize ??= size.height;
        for (var element in bgPlace) {
          _paintHorizontal(
              canvas, size, element.painter, element.start, element.end);
        }
        _paintHorizontal(canvas, size, painter, start, end);
        for (var element in fgPlace) {
          _paintHorizontal(
              canvas, size, element.painter, element.start, element.end);
        }
        break;
      case Axis.vertical:
        lineSize ??= size.width;
        for (var element in bgPlace) {
          _paintVertical(
              canvas, size, element.painter, element.start, element.end);
        }
        _paintVertical(canvas, size, painter, start, end);
        for (var element in fgPlace) {
          _paintVertical(
              canvas, size, element.painter, element.start, element.end);
        }
        break;
    }
  }

  void _paintVertical(
      Canvas canvas, Size size, BoxPainter painter, double start, double end) {
    var startPos = size.height * start;
    var endPos = size.height * end;

    double startX = 0;
    var lineWidth = min(lineSize ?? double.infinity, size.width);

    startPos += padding.top;
    endPos -= padding.bottom;

    startX = padding.left;
    lineWidth = lineWidth - padding.left + padding.right;

    if (startPos >= endPos) {
      return;
    }

    final length = endPos - startPos;

    if (maxLength != null && maxLength! < length) {
      var halfLength = maxLength!.divide(2);

      var minPos = startPos + halfLength;
      var maxPos = endPos - halfLength;
      var rect = Rect.fromLTRB(0, minPos, size.width, maxPos);
      var startOffset = alignment.withinRect(rect);

      startPos = startOffset.dy - halfLength;
      endPos = startPos + maxLength!;
    }

    if (dashStyle != null) {
      final x = startX;
      var y = startPos;
      final dashPath = Path();
      while (y <= endPos) {
        dashPath.addRect(Rect.fromLTWH(x, y, lineWidth, dashStyle!.width));
        y += dashStyle!.width + dashStyle!.gap;
      }
      canvas.save();
      canvas.clipPath(dashPath);
      painter.paint(
        canvas,
        Offset(startX, startPos),
        ImageConfiguration(
          size: Size(lineWidth, endPos - startPos),
        ),
      );
      canvas.restore();
    } else {
      painter.paint(
        canvas,
        Offset(startX, startPos),
        ImageConfiguration(
          size: Size(lineWidth, endPos - startPos),
        ),
      );
    }
  }

  void _paintHorizontal(
      Canvas canvas, Size size, BoxPainter painter, double start, double end) {
    var startPos = size.width * start;
    var endPos = size.width * end;

    double startY = 0;
    var lineWidth = min(lineSize ?? double.infinity, size.height);

    startPos += padding.left;
    endPos -= padding.right;
    startY = padding.top;
    lineWidth = lineWidth - padding.top + padding.bottom;

    if (startPos >= endPos) {
      return;
    }

    final length = endPos - startPos;

    // 如果有最大長度, 則進行修正
    if (maxLength != null && maxLength! < length) {
      final halfLength = NumUtil.divide(maxLength!, 2);

      final minPos = startPos + halfLength;
      final maxPos = endPos - halfLength;
      final rect = Rect.fromLTRB(minPos, 0, maxPos, size.height);
      final startOffset = alignment.withinRect(rect);

      startPos = startOffset.dx - halfLength;
      endPos = startPos + maxLength!;
    }

    if (dashStyle != null) {
      var x = startPos;
      final y = startY;
      final dashPath = Path();
      while (x <= endPos) {
        dashPath.addRect(Rect.fromLTWH(x, y, dashStyle!.width, lineWidth));
        x += dashStyle!.width + dashStyle!.gap;
      }
      canvas.save();
      canvas.clipPath(dashPath);
      painter.paint(
        canvas,
        Offset(startPos, startY),
        ImageConfiguration(
          size: Size(endPos - startPos, lineWidth),
        ),
      );
      canvas.restore();
    } else {
      painter.paint(
        canvas,
        Offset(startPos, startY),
        ImageConfiguration(
          size: Size(endPos - startPos, lineWidth),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is _LinePainter) {
      return painter != oldDelegate.painter ||
          start != oldDelegate.start ||
          end != oldDelegate.end;
    }
    return false;
  }
}
