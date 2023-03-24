import 'dart:ui';

/// 主圖表的顏色設定檔
class MainChartColorSetting {
  /// 背景顏色
  final Color background;

  /// ma各週期顏色, 依照週期長短排序
  final List<Color> maLine;

  /// boll指標顏色
  final Color bollUp;
  final Color bollDn;
  final Color bollMb;

  /// 漲價/跌價顏色
  final Color upColor;
  final Color downColor;

  /// 折線圖的線條顏色
  final Color timeLine;

  /// 跨越整個畫布的實時線顏色
  final Color realTimeLine;

  /// 跨越整個畫布的實時線數值背景
  final Color realTimeValueBg;

  /// 跨越整個畫布的實時線數值背景外框
  final Color realTimeValueBorder;

  /// 跨越整個畫布的實時線數值
  final Color realTimeValue;

  /// 跨越整個畫布的實時線三角標示
  final Color realTimeTriangleTag;

  /// 最右側的實時數值
  final Color realTimeRightValue;

  /// 最右側的實時線顏色
  final Color realTimeRightLine;

  /// 最右側的實時數值背景
  final Color realTimeRightValueBg;

  /// 最右側實時數值閃爍原點
  final List<Color> realTimeRightPointFlash;

  /// 折線圖的漸變渲染
  final List<Color> timeLineShadow;

  /// 圖表右側的數值說明顏色
  final Color rightValueText;

  /// 最小值/最大值文字
  final Color minValueText;
  final Color maxValueText;

  /// 頂部分隔線
  final Color topDivider;

  /// 底部分隔線
  final Color bottomDivider;

  const MainChartColorSetting({
    this.background = const Color(0xff1e2129),
    this.maLine = const [
      Color(0xffb47731),
      Color(0xffae33ba),
      Color(0xff59d0d0),
      Color(0xff59d0d0),
    ],
    this.upColor = const Color(0xff26a39d),
    this.downColor = const Color(0xffd55c5a),
    this.timeLine = const Color(0xff4C86CD),
    this.timeLineShadow = const [
      Color(0x554C86CD),
      Color(0x001e2129),
    ],
    this.bollMb = const Color(0xffb47731),
    this.bollUp = const Color(0xffae33ba),
    this.bollDn = const Color(0xff59d0d0),
    this.realTimeLine = const Color(0xff4C86CD),
    this.rightValueText = const Color(0xff60738E),
    this.realTimeValueBg = const Color(0x990D1722),
    this.realTimeValueBorder = const Color(0xffffffff),
    this.realTimeValue = const Color(0xffffffff),
    this.realTimeTriangleTag = const Color(0xffffffff),
    this.realTimeRightValue = const Color(0xff4C86CD),
    this.realTimeRightLine = const Color(0xffffffff),
    this.realTimeRightValueBg = const Color(0xff0D1722),
    this.realTimeRightPointFlash = const [
      Color(0xFFFFFFFF),
      Color(0x00FFFFFF),
    ],
    this.minValueText = const Color(0xffffffff),
    this.maxValueText = const Color(0xffffffff),
    this.topDivider = const Color(0xff4C86CD),
    this.bottomDivider = const Color(0xff4C86CD),
  });

  MainChartColorSetting copyWith({
    Color? background,
    List<Color>? maLine,
    Color? bollUp,
    Color? bollDn,
    Color? bollMb,
    Color? upColor,
    Color? downColor,
    Color? timeLine,
    Color? realTimeLine,
    Color? realTimeValueBg,
    Color? realTimeValueBorder,
    Color? realTimeValue,
    Color? realTimeTriangleTag,
    Color? realTimeRightValue,
    Color? realTimeRightLine,
    Color? realTimeRightValueBg,
    List<Color>? realTimeRightPointFlash,
    List<Color>? timeLineShadow,
    Color? rightValueText,
    Color? minValueText,
    Color? maxValueText,
    Color? topDivider,
    Color? bottomDivider,
  }) {
    return MainChartColorSetting(
      background: background ?? this.background,
      maLine: maLine ?? this.maLine,
      bollUp: bollUp ?? this.bollUp,
      bollDn: bollDn ?? this.bollDn,
      bollMb: bollMb ?? this.bollMb,
      upColor: upColor ?? this.upColor,
      downColor: downColor ?? this.downColor,
      timeLine: timeLine ?? this.timeLine,
      realTimeLine: realTimeLine ?? this.realTimeLine,
      realTimeValueBg: realTimeValueBg ?? this.realTimeValueBg,
      realTimeValueBorder: realTimeValueBorder ?? this.realTimeValueBorder,
      realTimeValue: realTimeValue ?? this.realTimeValue,
      realTimeTriangleTag: realTimeTriangleTag ?? this.realTimeTriangleTag,
      realTimeRightValue: realTimeRightValue ?? this.realTimeRightValue,
      realTimeRightLine: realTimeRightLine ?? this.realTimeRightLine,
      realTimeRightValueBg: realTimeRightValueBg ?? this.realTimeRightValueBg,
      realTimeRightPointFlash:
          realTimeRightPointFlash ?? this.realTimeRightPointFlash,
      timeLineShadow: timeLineShadow ?? this.timeLineShadow,
      rightValueText: rightValueText ?? this.rightValueText,
      minValueText: minValueText ?? this.minValueText,
      maxValueText: maxValueText ?? this.maxValueText,
      topDivider: topDivider ?? this.topDivider,
      bottomDivider: bottomDivider ?? this.bottomDivider,
    );
  }
}
