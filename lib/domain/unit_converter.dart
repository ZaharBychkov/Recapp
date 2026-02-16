import 'ingredient_unit.dart';

class UnitConverter {
  const UnitConverter();

  int toBase({
    required num amount,
    required IngredientUnit unit,
  }) {
    return (amount * unit.toBaseFactor).round();
  }

  double fromBase({
    required int baseAmount,
    required IngredientUnit targetUnit,
  }) {
    return baseAmount / targetUnit.toBaseFactor;
  }

  bool areCompatible(IngredientUnit a, IngredientUnit b) {
    return a.category == b.category;
  }

  String format({
    required int baseAmount,
    required IngredientUnit unit,
    int fractionDigits = 3,
  }) {
    final value = fromBase(baseAmount: baseAmount, targetUnit: unit);
    final fixed = value.toStringAsFixed(fractionDigits);
    final normalized = fixed.contains('.')
        ? fixed.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')
        : fixed;
    return '$normalized ${unit.symbol}';
  }
}
