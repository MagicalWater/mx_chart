import 'package:flutter/material.dart';
import 'package:mx_chart/mx_chart.dart';
import 'package:mx_chart/src/ui/k_line_chart/widget/line_indicator/line_indicator.dart';

import 'custom_global_price_tag.dart';

/// 自訂價格標示線
class CustomPriceLineTag extends StatelessWidget {
  final int gridColumns;

  final String Function(num price) priceFormatter;

  /// 說明標示
  final String? tag;

  /// 價格
  final double price;

  /// 位置
  final PricePosition position;

  /// 主題色
  final Color themeColor;

  /// 說明標示
  final TextStyle tagStyle;

  /// 在最右方時的價格標示
  final TextStyle rightPriceStyle;

  /// 全局的價格標示樣式
  final TextStyle globalPriceStyle;

  /// 點擊全局的tag
  final VoidCallback? onTapGlobalTag;

  const CustomPriceLineTag({
    Key? key,
    required this.gridColumns,
    required this.price,
    required this.position,
    required this.priceFormatter,
    this.onTapGlobalTag,
    this.tag,
    this.themeColor = Colors.blueAccent,
    this.tagStyle = const TextStyle(fontSize: 10, color: Colors.white),
    this.rightPriceStyle = const TextStyle(fontSize: 10, color: Colors.white),
    this.globalPriceStyle = const TextStyle(fontSize: 10, color: Colors.white),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (position.rightSpace < _rightSidePriceWidth()) {
      return _global(context);
    } else {
      return _rightSide(context);
    }
  }

  /// 全局
  Widget _global(BuildContext context) {
    return Stack(
      children: [
        PositionLayout(
          xRatio: 0.5,
          yFixed: position.priceToY(price),
          child: _dashLine(context: context, color: themeColor),
        ),
        PositionLayout(
          xRatio: (gridColumns - 1) / gridColumns,
          yFixed: position.priceToY(price),
          child: CustomGlobalPriceTag(
            tag: priceFormatter(price),
            themeColor: themeColor,
            tagStyle: globalPriceStyle,
            onTap: onTapGlobalTag,
          ),
        ),
        PositionLayout(
          xRatio: 0,
          yFixed: position.priceToY(price),
          anchorPoint: Alignment.centerLeft,
          child: _leftTag(context),
        ),
      ],
    );
  }

  /// 最右側實時
  Widget _rightSide(BuildContext context) {
    return Stack(
      children: [
        PositionLayout(
          xRatio: 0.5,
          yFixed: position.priceToY(price),
          child: _dashLine(context: context, color: themeColor),
        ),
        PositionLayout(
          xRatio: 1,
          yFixed: position.priceToY(price),
          anchorPoint: Alignment.centerRight,
          child: _rightSidePrice(context),
        ),
        PositionLayout(
          xRatio: 0,
          yFixed: position.priceToY(price),
          anchorPoint: Alignment.centerLeft,
          child: _leftTag(context),
        ),
      ],
    );
  }

  /// 最左側的文字標示
  Widget _leftTag(BuildContext context) {
    if (tag == null) {
      return const SizedBox.shrink();
    }
    return Container(
      color: themeColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 0.5,
      ),
      child: Text(tag!, style: tagStyle),
    );
  }

  /// 最右側的價格樣式
  Widget _rightSidePrice(BuildContext context) {
    return Container(
      color: themeColor,
      child: Text(priceFormatter(price), style: rightPriceStyle),
    );
  }

  /// 取得最右側價格所需寬度
  double _rightSidePriceWidth() {
    final priceText = priceFormatter(price);
    final textSpan = TextSpan(text: priceText, style: rightPriceStyle);
    final painter = TextPainter(
      text: TextSpan(children: [textSpan]),
      textDirection: TextDirection.ltr,
    );
    painter.layout();

    final textWidth = painter.size.width;
    return textWidth;
  }

  /// 虛線
  Widget _dashLine({required BuildContext context, required Color color}) {
    return LineIndicator(
      start: 0,
      end: 1,
      animation: false,
      color: color,
      size: 1,
      dashStyle: const DashStyle(5, 4),
    );
  }
}
