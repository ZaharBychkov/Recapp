enum UnitCategory {
  mass,
  volume,
  pieces,
}

enum IngredientUnit {
  mg,
  g,
  kg,
  ml,
  l,
  pcs,
}

extension IngredientUnitX on IngredientUnit {
  String get symbol {
    switch (this) {
      case IngredientUnit.mg:
        return 'мг';
      case IngredientUnit.g:
        return 'г';
      case IngredientUnit.kg:
        return 'кг';
      case IngredientUnit.ml:
        return 'мл';
      case IngredientUnit.l:
        return 'л';
      case IngredientUnit.pcs:
        return 'шт';
    }
  }

  UnitCategory get category {
    switch (this) {
      case IngredientUnit.mg:
      case IngredientUnit.g:
      case IngredientUnit.kg:
        return UnitCategory.mass;
      case IngredientUnit.ml:
      case IngredientUnit.l:
        return UnitCategory.volume;
      case IngredientUnit.pcs:
        return UnitCategory.pieces;
    }
  }

  int get toBaseFactor {
    switch (this) {
      case IngredientUnit.mg:
        return 1;
      case IngredientUnit.g:
        return 1000;
      case IngredientUnit.kg:
        return 1000000;
      case IngredientUnit.ml:
        return 1;
      case IngredientUnit.l:
        return 1000;
      case IngredientUnit.pcs:
        return 1000;
    }
  }

  static IngredientUnit fromSymbol(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'мг':
        return IngredientUnit.mg;
      case 'г':
        return IngredientUnit.g;
      case 'кг':
        return IngredientUnit.kg;
      case 'мл':
        return IngredientUnit.ml;
      case 'л':
        return IngredientUnit.l;
      case 'шт':
      case 'шт.':
        return IngredientUnit.pcs;
      default:
        throw ArgumentError('Unsupported unit symbol: $value');
    }
  }
}
