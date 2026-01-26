import '../models/ingredient.dart';

class IngredientChecker {
  static bool hasAllIngredients({
    required List<Ingredient> recipeIngredients,
    required List<Ingredient> fridgeIngredients,
}) {
    //Логика проверки от противного (быстрее для работы)
    for (final recipeIng in recipeIngredients) {       //Берем ингредиент из списка ингредиентов в рецепте
      final exists = fridgeIngredients.any(            //Даем холодильнику задачу сверять ингредиент со всеми элементами внунтри списка ингредиентов рецепта
          (fridgeIng) =>                                                                  //Лямбда выражение
              fridgeIng.name.trim().toLowerCase() == recipeIng.name.trim().toLowerCase(),
      );

      if(!exists) return false;
    }
    return true;
  }
}