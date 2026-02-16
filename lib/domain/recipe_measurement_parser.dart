import 'ingredient_unit.dart';
import 'unit_converter.dart';

class ParsedMeasurement {
  final int baseAmount;
  final IngredientUnit unit;

  const ParsedMeasurement({
    required this.baseAmount,
    required this.unit,
  });

  String toCanonicalString(UnitConverter converter) {
    return converter.format(baseAmount: baseAmount, unit: unit);
  }
}

class RecipeMeasurementParser {
  final UnitConverter _converter;

  const RecipeMeasurementParser({UnitConverter converter = const UnitConverter()})
      : _converter = converter;

  ParsedMeasurement? parse(String raw) {
    final source = raw.trim().toLowerCase();
    if (source.isEmpty) return null;

    // Normalize commas in decimal numbers.
    final normalized = source.replaceAll(',', '.');

    final special = _parseSpecialCases(normalized);
    if (special != null) return special;

    // Examples: "200 г", "1/2 шт", "1.5 л"
    final direct = RegExp(r'^(\d+(?:\.\d+)?|\d+\/\d+)\s*(мг|г|кг|мл|л|шт\.?)(?:\b|$)')
        .firstMatch(normalized);
    if (direct != null) {
      final amount = _parseNumberToken(direct.group(1)!);
      final unit = IngredientUnitX.fromSymbol(direct.group(2)!);
      return ParsedMeasurement(
        baseAmount: _converter.toBase(amount: amount, unit: unit),
        unit: unit,
      );
    }

    // Ranges: "5-6 листьев" -> 6 шт
    final range = RegExp(r'^(\d+)\s*[-–]\s*(\d+)').firstMatch(normalized);
    if (range != null) {
      final maxValue = double.parse(range.group(2)!);
      return ParsedMeasurement(
        baseAmount: _converter.toBase(amount: maxValue, unit: IngredientUnit.pcs),
        unit: IngredientUnit.pcs,
      );
    }

    return null;
  }

  ParsedMeasurement? _parseSpecialCases(String source) {
    // "2 шт. (по 100 г)" -> 200 г
    final perEach = RegExp(r'^(\d+(?:\.\d+)?)\s*шт\.?\s*\(по\s*(\d+(?:\.\d+)?)\s*г\)')
        .firstMatch(source);
    if (perEach != null) {
      final count = double.parse(perEach.group(1)!);
      final grams = double.parse(perEach.group(2)!);
      final total = count * grams;
      return ParsedMeasurement(
        baseAmount: _converter.toBase(amount: total, unit: IngredientUnit.g),
        unit: IngredientUnit.g,
      );
    }

    if (source.contains('ст. лож')) {
      final n = _extractLeadingNumber(source) ?? 1.0;
      return ParsedMeasurement(
        baseAmount: _converter.toBase(amount: n * 15, unit: IngredientUnit.ml),
        unit: IngredientUnit.ml,
      );
    }

    if (source.contains('ч. лож')) {
      final n = _extractLeadingNumber(source) ?? 1.0;
      return ParsedMeasurement(
        baseAmount: _converter.toBase(amount: n * 5, unit: IngredientUnit.ml),
        unit: IngredientUnit.ml,
      );
    }

    if (source.contains('зуб') ||
        source.contains('лист') ||
        source.contains('ломтик') ||
        source.contains('щепот')) {
      final n = _extractLeadingNumber(source) ?? 1.0;
      return ParsedMeasurement(
        baseAmount: _converter.toBase(amount: n, unit: IngredientUnit.pcs),
        unit: IngredientUnit.pcs,
      );
    }

    if (source.contains('по вкусу') || source.contains('по желанию')) {
      return ParsedMeasurement(
        baseAmount: _converter.toBase(amount: 1, unit: IngredientUnit.g),
        unit: IngredientUnit.g,
      );
    }

    return null;
  }

  double _parseNumberToken(String token) {
    if (token.contains('/')) {
      final parts = token.split('/');
      if (parts.length == 2) {
        final numerator = double.tryParse(parts[0]) ?? 0;
        final denominator = double.tryParse(parts[1]) ?? 1;
        if (denominator == 0) return 0;
        return numerator / denominator;
      }
    }
    return double.parse(token);
  }

  double? _extractLeadingNumber(String value) {
    final match = RegExp(r'^(\d+(?:\.\d+)?|\d+\/\d+)').firstMatch(value);
    if (match == null) return null;
    return _parseNumberToken(match.group(1)!);
  }
}
