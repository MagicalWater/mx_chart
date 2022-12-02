import 'package:flutter/material.dart';

class KLineDataTooltipColorSetting {
  /// 背景色
  final Color background;

  /// 外框顏色
  final Color border;

  /// 前綴文字顏色
  final Color prefixText;

  /// 一般數值文字
  final Color valueText;

  /// 漲跌值/幅 上漲顏色
  final Color changedRateUp;
  final Color changedValueUp;

  /// 漲跌值/幅 下跌顏色
  final Color changedRateDown;
  final Color changedValueDown;

  const KLineDataTooltipColorSetting({
    this.background = const Color(0xff0D1722),
    this.border = const Color(0xff6C7A86),
    this.prefixText = Colors.white,
    this.valueText = Colors.white,
    this.changedRateUp = const Color(0xff26a39d),
    this.changedValueUp = const Color(0xff26a39d),
    this.changedRateDown = const Color(0xffd55c5a),
    this.changedValueDown = const Color(0xffd55c5a),
  });
}
