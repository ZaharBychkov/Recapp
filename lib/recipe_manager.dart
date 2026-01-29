import 'models/recipe.dart';
import 'recipe_repository.dart';

class RecipeManager {
  
  /// Получить все рецепты из базы данных
  List<Recipe> getRecipes() {
    return RecipeRepository.getAllRecipes();
  }
  
  /// Добавить новый рецепт
  Future<void> addRecipe(Recipe recipe) async {
    await RecipeRepository.addRecipe(recipe);
  }
  
  /// Получить следующий ID для нового рецепта
  int getNextId() {
    return RecipeRepository.getNextId();
  }
}