import 'package:flutter/material.dart';

import '../../../../clipper/clipper.dart';
import '../chart_render/impl/main_chart/ui_style/main_chart_ui_style.dart';

class GlobalRealTimePriceTag extends StatelessWidget {
  final String price;
  final MainChartUiStyle uiStyle;
  final VoidCallback? onTap;

  const GlobalRealTimePriceTag({
    Key? key,
    required this.price,
    required this.uiStyle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizes = uiStyle.sizeSetting;
    final colors = uiStyle.colorSetting;
    final textStyle = TextStyle(
      color: colors.realTimeValue,
      fontSize: sizes.realTimeLineValue,
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: colors.realTimeValueBorder),
        color: colors.realTimeValueBg,
      ),
      child: Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.realTimeTagHorizontalPadding,
              vertical: sizes.realTimeTagVerticalPadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(price, style: textStyle),
                SizedBox(width: sizes.realTimeTagHorizontalPadding),
                _triangle(
                    colors.realTimeTriangleTag, sizes.realTimeTagTriangle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _triangle(Color color, Size size) {
    return ClipPath(
      clipper: PointClipper(
        points: [
          [
            const Offset(0, 0),
            const Offset(1, 0.5),
            const Offset(0, 1),
          ],
        ],
      ),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: color,
        ),
      ),
    );
  }
}