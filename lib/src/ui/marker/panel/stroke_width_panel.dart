import 'package:flutter/material.dart';

/// 線條寬度設定面板
class StrokeWidthPanel extends StatelessWidget {
  final VoidCallback onTap;
  final double strokeWidth;

  const StrokeWidthPanel({
    Key? key,
    required this.strokeWidth,
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
            child: Container(
              height: strokeWidth,
              decoration: const BoxDecoration(color: Colors.white),
            ),
          ),
          const Icon(Icons.arrow_drop_down_sharp, size: 15),
        ],
      ),
    );
  }
}

/// 線條設定面板詳細資訊
class StrokeWidthPanelDetail extends StatelessWidget {
  /// 線條寬度列表
  final List<double> strokeWidths;

  /// 每一個列表的高度
  final double itemWidth;

  /// 每一個列表的高度
  final double itemHeight;

  /// 最終選擇的寬度
  final ValueChanged<double> onChanged;

  const StrokeWidthPanelDetail({
    Key? key,
    required this.itemWidth,
    required this.itemHeight,
    required this.strokeWidths,
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
          strokeWidths.length,
          (index) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                onChanged(strokeWidths[index]);
              },
              child: SizedBox(
                height: itemHeight,
                child: Align(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Container(
                    width: itemWidth,
                    height: strokeWidths[index],
                    decoration: const BoxDecoration(color: Colors.white),
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
