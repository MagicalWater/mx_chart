import 'dart:core';

import 'package:intl/intl.dart';

extension DateUtilEx on DateTime {
  bool get isLeapYear => DateUtil.isLeapYear(year);

  String getDateStr({
    String format = "yyyy-MM-dd HH:mm:ss",
    String? sameDayFormat,
    String? differentDayFormat,
    String Function(Duration diff)? builder,
  }) =>
      DateUtil.getDateStr(
        this,
        format: format,
        sameDayFormat: sameDayFormat,
        differentDayFormat: differentDayFormat,
        builder: builder,
      );

  bool isYearEqual(DateTime other) => DateUtil.yearIsEqual(this, other);

  bool isMonthEqual(DateTime other) => DateUtil.monthIsEqual(this, other);

  bool isDayEqual(DateTime other) => DateUtil.dayIsEqual(this, other);

  bool isHourEqual(DateTime other) => DateUtil.hourIsEqual(this, other);

  bool isMinuteEqual(DateTime other) => DateUtil.minuteIsEqual(this, other);

  /// 取得時間差距
  int getDiff(DateTime other, DateType type) =>
      DateUtil.getDiff(this, other, type);
}

class DateUtil {
  DateUtil._();

  /// 得到某年的每月天數
  /// 閏年2月有29天
  /// 平年2月有28天
  /// 當 date 與 year 都帶時, 以 year 為主, 當都沒有帶時, 默認為今年
  static List<int> getYearMonthDay(int year) {
    var februaryDays = isLeapYear(year) ? 29 : 28;
    return [
      31, // 1月
      februaryDays, // 2月
      31, // 3月
      30, // 4月
      31, // 5月
      30, // 6月
      31, // 7月
      31, // 8月
      30, // 9月
      31, // 10月
      30, // 11月
      31, // 13月
    ];
  }

  /// 是否為閏年, 默認為今天
  /// 當 date 與 year 都帶時, 以 year 為主, 當都沒有帶時, 默認為今年
  /// 平年 - 2月 有28天
  /// 閏年 - 2月 有29天
  /// 判斷是否閏年, 滿足以下其中一條件即可
  /// 1. 年數是否能被4整除, 且不能被100整除
  /// 2. 能被400整除
  static bool isLeapYear(
    int year,
  ) {
    var y = year;
    if ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) {
      return true;
    } else {
      return false;
    }
  }

  /// [date] 默認為今天
  /// [format] 預設格式
  /// [sameDayFormat]   同一天時的格式
  /// [differentDayFormat]  不同天的格式
  /// [builder] 自訂格式, function 回調 [dateTime] 與當前的時間差距
  ///   * 當實現 [builder], 則 [format], [sameDayFormat], [differentDayFormat] 失效
  static String getDateStr(
    DateTime date, {
    String format = "yyyy-MM-dd HH:mm:ss",
    String? sameDayFormat,
    String? differentDayFormat,
    String Function(Duration diff)? builder,
  }) {
    var baseDate = date;
    String dateFormat;
    if (builder != null) {
      dateFormat = builder(baseDate.difference(DateTime.now()));
    } else if (DateUtil.dayIsEqual(DateTime.now(), baseDate)) {
      dateFormat = sameDayFormat ?? format;
    } else {
      dateFormat = differentDayFormat ?? format;
    }
    return DateFormat(dateFormat).format(baseDate);
  }

  /// 是否同年
  static bool yearIsEqual(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }

  /// 是否同一月
  static bool monthIsEqual(
    DateTime date1,
    DateTime date2,
  ) {
    return yearIsEqual(date1, date2) && date1.month == date2.month;
  }

  /// 是否同一天
  static bool dayIsEqual(DateTime date1, DateTime date2) {
    return monthIsEqual(date1, date2) && date1.day == date2.day;
  }

  /// 是否同一小時
  static bool hourIsEqual(DateTime date1, DateTime date2) {
    return dayIsEqual(date1, date2) && date1.hour == date2.hour;
  }

  /// 是否同一分鐘
  static bool minuteIsEqual(DateTime date1, DateTime date2) {
    return hourIsEqual(date1, date2) && date1.minute == date2.minute;
  }

  /// 取得兩個時間的差距
  static int getDiff(DateTime date1, DateTime date2, DateType type) {
    var duration = date2.difference(date1);
    var diff = 0;
    switch (type) {
      case DateType.year:
        diff = (date2.year - date1.year).abs();
        break;
      case DateType.month:
        if (date2.year == date1.year) {
          /// 同年, 直接計算月份差距
          diff = (date2.month - date1.month).abs();
          break;
        }

        /// 起始年份
        var startDate = date1.isAfter(date2) ? date2 : date1;
        var endDate = date1.isAfter(date2) ? date1 : date2;
        var startYear = startDate.year;

        /// 兩個日期的差距年份
        var years = List.generate(
          endDate.year - startDate.year,
          (index) {
            return startYear + index;
          },
        );

        /// 拿掉前後兩個年份
        years
          ..removeAt(0)
          ..removeLast();

        /// 中間的年份共有 長度*12 個月
        var centerCount = years.length * 12;

        /// 前後共有幾個月
        var sideCount = (12 - startDate.month) + endDate.month;
        diff = centerCount + sideCount;
        break;
      case DateType.day:
        diff = duration.inDays;
        break;
      case DateType.hour:
        diff = duration.inHours;
        break;
      case DateType.minute:
        diff = duration.inHours;
        break;
      case DateType.second:
        diff = duration.inSeconds;
        break;
    }
    return diff;
  }
}

/// 日期差值, 用來進行日期差值計算
class DateDiff {
  /// 差值類型
  DateType type;

  /// 差值數值
  int diff;

  DateDiff({required this.type, required this.diff});
}

/// 日期類型
enum DateType {
  year,
  month,
  day,
  hour,
  minute,
  second,
}
