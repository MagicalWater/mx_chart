import 'package:flutter/material.dart';

class ChartColorSetting {
  /// 格線顏色
  final Color grid;

  /// 長按時的交叉線豎線顏色
  final Color longPressVerticalLine;

  /// 長按時的交叉線橫顏色
  final Color longPressHorizontalLine;

  /// 長按時的交叉圓點顏色
  final Color longPressCrossPoint;

  /// 長按時, 對應y軸的數值
  final Color longPressValue;

  /// 長按時, 對應y軸的數值背景
  final Color longPressValueBg;

  /// 長按時, 對應y軸的數值邊框
  final Color longPressValueBorder;

  /// 長按時, 對應x軸的時間
  final Color longPressTime;

  /// 長按時, 對應y軸的數值背景
  final Color longPressTimeBg;

  /// 長按時, 對應y軸的數值邊框
  final Color longPressTimeBorder;

  /// 下方時間軸的文字顏色
  final Color bottomTimeText;

  /// 下方時間軸的背景
  final Color bottomTimeBg;

  /// 下方時間軸的線條
  final Color bottomTimeLine;

  /// 主圖表下方的拖曳bar, 一般型態時的顏色
  final Color dragBar;
  final Color dragBarDragging;

  /// 拖曳bar的拖曳狀態箭頭顏色
  final Color dragBarTriangle;

  /// 右方數值軸的線條
  final Color rightValueLine;

  const ChartColorSetting({
    this.grid = const Color(0xff2c303e),
    this.longPressVerticalLine = Colors.white12,
    this.longPressHorizontalLine = Colors.white,
    this.longPressCrossPoint = Colors.white,
    this.longPressValue = Colors.white,
    this.longPressValueBg = const Color(0xff0D1722),
    this.longPressValueBorder = const Color(0xff6C7A86),
    this.longPressTime = Colors.white,
    this.longPressTimeBg = const Color(0xff0D1722),
    this.longPressTimeBorder = const Color(0xff6C7A86),
    this.bottomTimeText = const Color(0xff60738E),
    this.bottomTimeBg = const Color(0xff1e2129),
    this.bottomTimeLine = const Color(0xff3d6086),
    this.dragBar = const Color(0xff3d6086),
    this.dragBarDragging = const Color(0xff3d6086),
    this.dragBarTriangle = const Color(0xffb1bfd0),
    this.rightValueLine = const Color(0xff3d6086),
  });
}
