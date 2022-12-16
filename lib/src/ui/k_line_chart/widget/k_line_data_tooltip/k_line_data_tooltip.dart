import 'package:flutter/material.dart';
import 'package:mx_chart/src/util/date_util.dart';
import 'package:mx_chart/src/util/num_util/num_util.dart';

import '../../model/model.dart';
import 'k_line_data_tooltip.dart';

export 'model/model.dart';
export 'ui_style/k_line_data_tooltip_ui_style.dart';

/// 長按對應的k線資料彈窗
class KLineDataInfoTooltip extends StatelessWidget {
  final LongPressData longPressData;
  final KLineDataTooltipUiStyle uiStyle;
  final TooltipPrefix tooltipPrefix;
  final String Function(DateTime dateTime) dateTimeFormatter;

  /// 價格格式化
  final String Function(num price) priceFormatter;

  /// 成交量格式化
  final String Function(num volume)? volumeFormatter;

  KLineData get data => longPressData.data;

  KLineData? get prevData => longPressData.prevData;

  KLineDataTooltipColorSetting get colors => uiStyle.colorSetting;

  KLineDataTooltipSizeSetting get sizes => uiStyle.sizeSetting;

  static String _defaultDateTimeFormatter(DateTime dateTime) {
    return dateTime.getDateStr(format: 'yyyy-MM-dd HH:mm');
  }

  /// 預設價格格式化
  static String _defaultPriceFormatter(num price) {
    return price.toStringAsFixed(2);
  }

  /// 預設成交量格式化
  String _defaultVolumeFormatter(num volume) {
    if (volume > 10000 && volume < 999999) {
      final d = volume / 1000;
      return '${priceFormatter(d)}K';
    } else if (volume > 1000000) {
      final d = volume / 1000000;
      return '${priceFormatter(d)}M';
    }
    return priceFormatter(volume);
  }

  const KLineDataInfoTooltip({
    Key? key,
    required this.longPressData,
    this.uiStyle = const KLineDataTooltipUiStyle(),
    this.tooltipPrefix = const TooltipPrefix(),
    this.dateTimeFormatter = _defaultDateTimeFormatter,
    this.priceFormatter = _defaultPriceFormatter,
    this.volumeFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: longPressData.isLongPressAtLeft
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: sizes.horizontalMargin,
          right: sizes.horizontalMargin,
          top: sizes.topMargin,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: sizes.horizontalPadding,
          vertical: sizes.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border, width: sizes.borderWidth),
        ),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _date(),
              _open(),
              _close(),
              _high(),
              _low(),
              _changedValueAndRate(),
              _volume(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _date() {
    return _item(
      prefix: tooltipPrefix.time,
      value: dateTimeFormatter(data.dateTime),
    );
  }

  Widget _open() {
    return _item(
      prefix: tooltipPrefix.open,
      value: priceFormatter(data.open),
    );
  }

  Widget _close() {
    return _item(
      prefix: tooltipPrefix.close,
      value: priceFormatter(data.close),
    );
  }

  Widget _high() {
    return _item(
      prefix: tooltipPrefix.high,
      value: priceFormatter(data.high),
    );
  }

  Widget _low() {
    return _item(
      prefix: tooltipPrefix.low,
      value: priceFormatter(data.low),
    );
  }

  Widget _changedValueAndRate() {
    final prevClose = prevData?.close;
    if (prevClose == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _item(
            prefix: tooltipPrefix.changeValue,
            value: '- -',
            valueColor: colors.valueText,
          ),
          _item(
            prefix: tooltipPrefix.changeRate,
            value: '- -',
            valueColor: colors.valueText,
          ),
        ],
      );
    }
    final changedValue = data.close - prevClose;
    Color valueColor, rateColor;
    if (changedValue > 0) {
      valueColor = colors.changedValueUp;
      rateColor = colors.changedRateUp;
    } else if (changedValue < 0) {
      valueColor = colors.changedValueDown;
      rateColor = colors.changedRateDown;
    } else {
      valueColor = colors.valueText;
      rateColor = colors.valueText;
    }
    final changedRate = changedValue.divide(prevClose) * 100;

    var changeValueText = priceFormatter(changedValue);
    var changeRateText = '${changedRate.toStringAsFixed(2)}%';

    if (changedValue >= 0) {
      changeValueText = '+$changeValueText';
      changeRateText = '+$changeRateText';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _item(
          prefix: tooltipPrefix.changeValue,
          value: changeValueText,
          valueColor: valueColor,
        ),
        _item(
          prefix: tooltipPrefix.changeRate,
          value: changeRateText,
          valueColor: rateColor,
        ),
      ],
    );
  }

  Widget _volume() {
    return _item(
      prefix: tooltipPrefix.volume,
      value: volumeFormatter?.call(data.volume) ??
          _defaultVolumeFormatter(data.volume),
    );
  }

  Widget _item({
    required String prefix,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              prefix,
              style: TextStyle(
                color: colors.prefixText,
                fontSize: sizes.prefixText,
              ),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colors.valueText,
            fontSize: sizes.valueText,
          ),
        ),
      ],
    );
  }
}
