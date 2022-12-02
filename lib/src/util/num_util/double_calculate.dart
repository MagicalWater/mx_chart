import 'dart:math';

import 'package:decimal/decimal.dart';

import 'num_util.dart';

extension DoubleCalculate on double {
  double add(num other) => NumUtil.add(this, other);

  double subtract(num other) => NumUtil.subtract(this, other);

  double multiply(num other) => NumUtil.multiply(this, other);

  double divide(
    num other, {
    int? scaleOnInfinitePrecision = 10,
    BigInt Function(Rational rational)? toBigInt,
  }) =>
      NumUtil.divide(
        this,
        other,
        scaleOnInfinitePrecision: scaleOnInfinitePrecision,
        toBigInt: toBigInt,
      );

  /// 四捨五入到固定小數點
  double roundToFixed(int fractionDigits) {
    final fac = pow(10, fractionDigits).toInt();
    final multipleFac = fac.multiply(this).round();
    return multipleFac.divide(fac).toDouble();
  }

  /// 無條件捨去到固定小數點
  double floorToFixed(int fractionDigits) {
    final fac = pow(10, fractionDigits).toInt();
    final multipleFac = fac.multiply(this).floor();
    return multipleFac.divide(fac).toDouble();
  }

  /// 無條件進位到固定小數點
  double ceilToFixed(int fractionDigits) {
    final fac = pow(10, fractionDigits).toInt();
    final multipleFac = fac.multiply(this).ceil();
    return multipleFac.divide(fac).toDouble();
  }

  /// 取得小數點有幾位
  /// 小數點尾數為0則會去除
  /// 例如
  /// (10.0).decimalLength 會得到 0
  /// (10.10).decimalLength 會得到 1
  int get decimalLength {
    final convertedNum = Decimal.parse(toString());
    var showString = convertedNum.toString();
    var pointIndex = showString.indexOf('.');
    if (pointIndex == -1) {
      return 0;
    } else {
      var decString = showString.substring(pointIndex);
      var len = decString.length;
      if (len == 2 && decString[1] == '0') {
        return 0;
      }
      return len - 1;
    }
  }
}
