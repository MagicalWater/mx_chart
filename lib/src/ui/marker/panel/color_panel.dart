import 'package:flutter/material.dart';

/// 標記顏色設定面板
class ColorPanel extends StatelessWidget {
  final VoidCallback onTap;

  /// 當前的顏色
  final Color color;

  const ColorPanel({
    Key? key,
    required this.color,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.edit, size: 15),
                const SizedBox(height: 2,),
                Flexible(
                  child: Container(
                    width: double.infinity,
                    color: color,
                    constraints: const BoxConstraints(maxHeight: 3),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_drop_down_sharp, size: 15),
        ],
      ),
    );
  }
}

/// 虛線設定面板詳細資訊
class ColorPanelDetail extends StatelessWidget {
  /// 虛線設定列表
  final List<Color> colors;

  /// 單個顏色區塊的高度
  final double itemWidth;

  /// 單個顏色區塊的高度
  final double itemHeight;

  /// 最終選擇的顏色
  final ValueChanged<Color> onChanged;

  /// 每個物件彼此的距離
  final double space;

  const ColorPanelDetail({
    Key? key,
    required this.itemWidth,
    required this.itemHeight,
    required this.colors,
    required this.onChanged,
    this.space = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 一列幾個item
    const crossAxisCount = 3;

    final totalWidth =
        (itemWidth * crossAxisCount) + (space * (crossAxisCount + 1));
    return SizedBox(
      width: totalWidth,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: space,
          horizontal: space,
        ),
        child: Wrap(
          spacing: space,
          runSpacing: space,
          children: [
            ...colors.map((e) {
              return GestureDetector(
                onTap: () => onChanged(e),
                child: SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: e,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
