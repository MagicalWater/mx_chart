import 'dart:typed_data';
import 'dart:ui';

/// 可反轉的路徑
class ReversiblePath {
  Path get entity => _realPath;

  final _realPath = Path();

  final List<_Operation> _operations = [];

  Offset _currentPoint = Offset.zero;

  void moveTo(double x, double y) {
    _realPath.moveTo(x, y);

    final operation = _Operation(
      type: _OperationType.moveTo,
      args: [x, y],
      startPoint: _currentPoint,
      endPoint: Offset(x, y),
    );

    _operations.add(operation);

    _currentPoint = Offset(x, y);
  }

  void lineTo(double x, double y) {
    _realPath.lineTo(x, y);

    final operation = _Operation(
      type: _OperationType.lineTo,
      args: [x, y],
      startPoint: _currentPoint,
      endPoint: Offset(x, y),
    );

    _operations.add(operation);

    _currentPoint = Offset(x, y);
  }

  void conicTo(double x1, double y1, double x2, double y2, double w) {
    _realPath.conicTo(x1, y1, x2, y2, w);

    final operation = _Operation(
      type: _OperationType.conicTo,
      args: [x1, y1, x2, y2, w],
      startPoint: _currentPoint,
      endPoint: Offset(x2, y2),
    );

    _operations.add(operation);

    _currentPoint = Offset(x2, y2);
  }

  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _realPath.cubicTo(x1, y1, x2, y2, x3, y3);

    final operation = _Operation(
      type: _OperationType.cubicTo,
      args: [x1, y1, x2, y2, x3, y3],
      startPoint: _currentPoint,
      endPoint: Offset(x3, y3),
    );

    _operations.add(operation);

    _currentPoint = Offset(x3, y3);
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _realPath.quadraticBezierTo(x1, y1, x2, y2);

    final operation = _Operation(
      type: _OperationType.quadraticBezierTo,
      args: [x1, y1, x2, y2],
      startPoint: _currentPoint,
      endPoint: Offset(x2, y2),
    );

    _operations.add(operation);

    _currentPoint = Offset(x2, y2);
  }

  /// 進行反轉
  Path reverse() {
    final path = Path();

    bool isFirst = true;

    for (var element in _operations.reversed) {
      if (isFirst) {
        path.moveTo(element.endPoint.dx, element.endPoint.dy);
        isFirst = false;
      }

      switch (element.type) {
        case _OperationType.moveTo:
          path.moveTo(
            element.startPoint.dx,
            element.startPoint.dy,
          );
          break;
        case _OperationType.lineTo:
          path.lineTo(
            element.startPoint.dx,
            element.startPoint.dy,
          );
          break;
        case _OperationType.conicTo:
          path.conicTo(
            element.args[0],
            element.args[1],
            element.args[2],
            element.args[3],
            element.args[4],
          );
          break;
        case _OperationType.cubicTo:
          path.cubicTo(
            element.args[0],
            element.args[1],
            element.args[2],
            element.args[3],
            element.startPoint.dx,
            element.startPoint.dy,
          );
          break;
        case _OperationType.quadraticBezierTo:
          path.quadraticBezierTo(
            element.args[0],
            element.args[1],
            element.startPoint.dx,
            element.startPoint.dy,
          );
          break;
      }
    }

    return path;
  }

  PathFillType get fillType => _realPath.fillType;

  set fillType(PathFillType value) {
    _realPath.fillType;
  }

  void close() {
    _realPath.close();
  }

  void extendWithPath(Path path, Offset offset, {Float64List? matrix4}) {
    _realPath.extendWithPath(path, offset, matrix4: matrix4);
  }

  PathMetrics computeMetrics({bool forceClosed = false}) {
    return _realPath.computeMetrics(forceClosed: forceClosed);
  }

  bool contains(Offset point) {
    return _realPath.contains(point);
  }

  Rect getBounds() {
    return _realPath.getBounds();
  }

  void reset() {
    _realPath.reset();
  }
}

class _Operation {
  final _OperationType type;
  final List<dynamic> args;
  final Offset startPoint, endPoint;

  _Operation({
    required this.type,
    required this.args,
    required this.startPoint,
    required this.endPoint,
  });
}

enum _OperationType { moveTo, lineTo, conicTo, cubicTo, quadraticBezierTo }
