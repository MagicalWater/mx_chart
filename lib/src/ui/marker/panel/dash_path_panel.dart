import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// 虛線路徑設定面板
class DashPathPanel extends StatelessWidget {
  final VoidCallback onTap;
  final List<double> dashArray;

  const DashPathPanel({
    Key? key,
    required this.dashArray,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(
              size: const Size.fromHeight(2),
              painter: DashPainter(color: Colors.white, dashArray: dashArray),
            ),
          ),
          const Icon(Icons.arrow_drop_down_sharp, size: 15),
        ],
      ),
    );
  }
}

class DashPainter extends CustomPainter {
  final List<double> dashArray;
  final Color color;
  final _paint = Paint()..style = PaintingStyle.stroke;

  DashPainter({
    required this.color,
    required this.dashArray,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);
    if (dashArray.isNotEmpty) {
      final toDashPath = dashPath(
        path,
        dashArray: CircularIntervalList(dashArray),
      );
      canvas.drawPath(
          toDashPath,
          _paint
            ..color = color
            ..strokeWidth = size.height);
    } else {
      canvas.drawPath(
          path,
          _paint
            ..color = color
            ..strokeWidth = size.height);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is DashPainter) {
      final oldLen = oldDelegate.dashArray.length;
      final newLen = dashArray.length;
      if (oldLen != newLen) {
        return true;
      } else {
        for (var i = 0; i < oldLen; i++) {
          if (oldDelegate.dashArray[i] != dashArray[i]) {
            return true;
          }
        }
      }
      return color != oldDelegate.color;
    }
    return false;
  }
}

/// 虛線設定面板詳細資訊
class DashPathPanelDetail extends StatelessWidget {
  /// 虛線設定列表
  final List<List<double>> dashArrays;

  /// 每一個列表的高度
  final double itemWidth;

  /// 每一個列表的高度
  final double itemHeight;

  /// 最終選擇的寬度
  final ValueChanged<List<double>> onChanged;

  const DashPathPanelDetail({
    Key? key,
    required this.itemWidth,
    required this.itemHeight,
    required this.dashArrays,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          dashArrays.length,
          (index) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                onChanged(dashArrays[index]);
              },
              child: SizedBox(
                height: itemHeight,
                child: Align(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: CustomPaint(
                    size: Size(itemWidth, 2),
                    painter: DashPainter(
                      color: Colors.white,
                      dashArray: dashArrays[index],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
