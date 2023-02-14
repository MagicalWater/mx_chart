import 'dart:ui';

/// 繪製圖表的各個通用方法
abstract class ChartComponentRender {
  /// 在此初始化並暫存所有數值
  void initValue(Rect rect);

  /// 繪製背景
  void paintBackground(Canvas canvas, Rect rect);

  /// 繪製格線
  void paintGrid(Canvas canvas, Rect rect);

  /// 繪製頂部/底部分隔線
  void paintDivider(Canvas canvas, Rect rect);

  /// 繪製最上方的說明文字
  void paintTopValueText(Canvas canvas, Rect rect);

  /// 繪製右邊的數值Tag文字
  void paintRightValueText(Canvas canvas, Rect rect);

  /// 繪製圖表
  void paintChart(Canvas canvas, Rect rect);
}