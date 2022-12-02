import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

export 'package:rational/rational.dart';

export 'double_calculate.dart';
export 'num_calculate.dart';

/// 來源 https://github.com/Sky24n
/// 原作者 Sky24n
/// 修改者 Water
///
/// 數字工具
class NumUtil {
  /// 加 (精确相加,防止精度丢失).
  static double add(num a, num b) {
    return addDec(a, b).toDouble();
  }

  /// 减 (精确相减,防止精度丢失).
  static double subtract(num a, num b) {
    return subtractDec(a, b).toDouble();
  }

  /// 乘 (精确相乘,防止精度丢失).
  /// multiply (without loosing precision).
  static double multiply(num a, num b) {
    return multiplyDec(a, b).toDouble();
  }

  /// 除 (精确相除,防止精度丢失).
  /// divide (without loosing precision).
  static double divide(
    num a,
    num b, {
    int? scaleOnInfinitePrecision = 10,
    BigInt Function(Rational rational)? toBigInt,
  }) {
    return divideDec(
      a,
      b,
      scaleOnInfinitePrecision: scaleOnInfinitePrecision,
      toBigInt: toBigInt,
    ).toDouble();
  }

  /// 加 (精确相加,防止精度丢失).
  /// add (without loosing precision).
  static Decimal addDec(num a, num b) {
    return addDecStr(a.toString(), b.toString());
  }

  /// 减 (精确相减,防止精度丢失).
  /// subtract (without loosing precision).
  static Decimal subtractDec(num a, num b) {
    return subtractDecStr(a.toString(), b.toString());
  }

  /// 乘 (精确相乘,防止精度丢失).
  /// multiply (without loosing precision).
  static Decimal multiplyDec(num a, num b) {
    return multiplyDecStr(a.toString(), b.toString());
  }

  /// 除 (精确相除,防止精度丢失).
  /// divide (without loosing precision).
  static Decimal divideDec(
    num a,
    num b, {
    int? scaleOnInfinitePrecision = 10,
    BigInt Function(Rational rational)? toBigInt,
  }) {
    return divideDecStr(
      a.toString(),
      b.toString(),
      scaleOnInfinitePrecision: scaleOnInfinitePrecision,
      toBigInt: toBigInt,
    );
  }

  /// 余数
  static Decimal remainder(num a, num b) {
    return remainderDecStr(a.toString(), b.toString());
  }

  /// 加
  static Decimal addDecStr(String a, String b) {
    return Decimal.parse(a) + Decimal.parse(b);
  }

  /// 减
  static Decimal subtractDecStr(String a, String b) {
    return Decimal.parse(a) - Decimal.parse(b);
  }

  /// 乘
  static Decimal multiplyDecStr(String a, String b) {
    return Decimal.parse(a) * Decimal.parse(b);
  }

  /// 除(除法可能出現有理數, 因此需要做轉換)
  /// [scaleOnInfinitePrecision] - 當除不盡時, 最大計算到小數點幾位
  static Decimal divideDecStr(
    String a,
    String b, {
    int? scaleOnInfinitePrecision = 10,
    BigInt Function(Rational rational)? toBigInt,
  }) {
    final value = Decimal.parse(a) / Decimal.parse(b);
    return value.toDecimal(
      scaleOnInfinitePrecision: scaleOnInfinitePrecision,
      toBigInt: toBigInt,
    );
  }

  /// 余数
  static Decimal remainderDecStr(String a, String b) {
    return Decimal.parse(a) % Decimal.parse(b);
  }
}
