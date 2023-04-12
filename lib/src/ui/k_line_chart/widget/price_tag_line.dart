import 'package:flutter/material.dart';

import '../../widget/position_layout.dart';
import '../model/model.dart';
import 'chart_render/impl/main_chart/ui_style/main_chart_ui_style.dart';
import 'global_real_tim_price_tag/global_real_time_price_tag.dart';
import 'line_indicator/line_indicator.dart';

/// 價格標示虛線
class PriceTagLine extends StatelessWidget {
  final int gridColumns;

  final double? globalTagOffsetX;

  final String Function(num price) priceFormatter;

  final MainChartUiStyle uiStyle;

  final double price;

  final PricePosition position;

  final double? rectTop;

  /// 點擊全局的tag
  final VoidCallback? onTapGlobalTag;

  const PriceTagLine({
    Key? key,
    required this.gridColumns,
    required this.price,
    required this.position,
    required this.uiStyle,
    required this.priceFormatter,
    this.rectTop,
    this.globalTagOffsetX,
    this.onTapGlobalTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!position.isNewerDisplay) {
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
          yFixed: position.valueToY(price) + (rectTop ?? 0),
          child: _dashLine(
            context: context,
            color: uiStyle.colorSetting.realTimeLine,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: globalTagOffsetX ?? 0),
          child: PositionLayout(
            xRatio: (gridColumns - 1) / gridColumns,
            yFixed: position.valueToY(price) + (rectTop ?? 0),
            child: GlobalRealTimePriceTag(
              price: priceFormatter(price),
              uiStyle: uiStyle,
              onTap: onTapGlobalTag,
            ),
          ),
        ),
      ],
    );
  }

  /// 最右側實時
  Widget _rightSide(BuildContext context) {
    final colorSetting = uiStyle.colorSetting;
    return PositionLayout(
      xRatio: 1,
      yFixed: position.valueToY(price) + (rectTop ?? 0),
      anchorPoint: Alignment.centerRight,
      child: SizedBox(
        width: position.rightSpace,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _dashLine(
                context: context,
                color: colorSetting.realTimeRightLine,
              ),
            ),
            _rightSidePrice(context),
          ],
        ),
      ),
    );
  }

  /// 最右側的價格樣式
  Widget _rightSidePrice(BuildContext context) {
    final colorSetting = uiStyle.colorSetting;
    final sizeSetting = uiStyle.sizeSetting;
    return Container(
      color: colorSetting.realTimeRightValueBg,
      child: Text(
        priceFormatter(price),
        style: TextStyle(
          fontSize: sizeSetting.rightValueText,
          color: colorSetting.realTimeRightValue,
        ),
      ),
    );
  }

  /// 取得最右側價格所需寬度
  // ignore: unused_element
  double _rightSidePriceWidth() {
    final colorSetting = uiStyle.colorSetting;
    final sizeSetting = uiStyle.sizeSetting;
    final priceText = priceFormatter(price);
    final textSpan = TextSpan(
      text: priceText,
      style: TextStyle(
        fontSize: sizeSetting.rightValueText,
        color: colorSetting.realTimeRightValue,
      ),
    );
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
