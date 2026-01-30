import 'models/recipe.dart';
import 'recipe_repository.dart';

//Все функции для хранения описал в repository этот файл теперь только вызывает эти функции и связывает 
//базу с UI - отправлет в recipe_ropsitory и далее в Hive (базу данных)
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