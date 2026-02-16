import '../domain/ingredient_unit.dart';
import '../domain/recipe_measurement_parser.dart';
import '../models/fridge/fridge_item.dart';
import '../models/ingredient.dart';

class RecipeAvailabilityResult {
  final bool hasAllIngredients;
  final List<String> missingNames;
  final List<FridgeItem> consumedSnapshot;
  final List<FridgeItem> updatedItems;

  const RecipeAvailabilityResult({
    required this.hasAllIngredients,
    required this.missingNames,
    required this.consumedSnapshot,
    required this.updatedItems,
  });
}

class RecipeAvailabilityService {
  final RecipeMeasurementParser _parser;

  const RecipeAvailabilityService({
    RecipeMeasurementParser parser = const RecipeMeasurementParser(),
  }) : _parser = parser;

  RecipeAvailabilityResult checkAndBuildConsumption({
    required List<Ingredient> recipeIngredients,
    required List<FridgeItem> fridgeItems,
  }) {
    final missing = <String>[];
    final updated = fridgeItems.map((e) => e).toList();
    final consumed = <FridgeItem>[];

    for (final recipeIngredient in recipeIngredients) {
      final parsed = _parser.parse(recipeIngredient.measurement);
      if (parsed == null) {
        missing.add(recipeIngredient.name);
        continue;
      }

      final index = updated.indexWhere((f) => f.name == recipeIngredient.name);
      if (index == -1) {
        missing.add(recipeIngredient.name);
        continue;
      }

      final fridge = updated[index];
      if (!_isCategoryCompatible(parsed.unit, fridge.unit)) {
        missing.add(recipeIngredient.name);
        continue;
      }

      if (fridge.amountBase < parsed.baseAmount) {
        missing.add(recipeIngredient.name);
        continue;
      }

      final newAmount = fridge.amountBase - parsed.baseAmount;
      updated[index] = fridge.copyWith(
        amountBase: newAmount,
        isDepleted: newAmount <= 0,
      );

      consumed.add(
        FridgeItem(
          id: fridge.id,
          name: fridge.name,
          amountBase: parsed.baseAmount,
          unit: fridge.unit,
          displayOrder: fridge.displayOrder,
          isDepleted: false,
        ),
      );
    }

    return RecipeAvailabilityResult(
      hasAllIngredients: missing.isEmpty,
      missingNames: missing,
      consumedSnapshot: consumed,
      updatedItems: updated,
    );
  }

  bool _isCategoryCompatible(IngredientUnit recipeUnit, IngredientUnit fridgeUnit) {
    return recipeUnit.category == fridgeUnit.category;
  }
}
