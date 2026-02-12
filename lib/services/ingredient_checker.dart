import '../models/ingredient.dart';

class IngredientChecker {
  static bool hasAllIngredients({
    required List<Ingredient> recipeIngredients,
    required List<Ingredient> fridgeIngredients,
}) {
    for (final Ingredient recipeIng in recipeIngredients) {
      final exists = fridgeIngredients.any(
          (fridgeIng) =>
              fridgeIng.name.trim().toLowerCase() == recipeIng.name.trim().toLowerCase(),
      );

      if (!exists) return false;
    }
    return true;
  }
}
