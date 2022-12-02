import 'num_util.dart';

extension NumCalculate on num {
  num add(num other) => NumUtil.add(this, other);

  num subtract(num other) => NumUtil.subtract(this, other);

  num multiply(num other) => NumUtil.multiply(this, other);

  num divide(
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
}
