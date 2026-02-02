import 'recipe_repository.dart';
import '../models/recipe.dart';


class RecipeManager {
  static final RecipeManager _instance = RecipeManager._internal(); //Создаем один экземпляр на одно приложение
  factory RecipeManager() => _instance;                              //Возвращаем один экземпляр где бы мы не вызвался RecipeManager
  RecipeManager._internal();                                         //Вызываем только внутри данного файла

  //Получить все рецепты из базы
  List<Recipe> getRecipes() {
    return RecipeRepository.getAllRecipes();
  }

  //Получить все рецепты с пометкой isFavorite
  List<Recipe> getFavoriteRecipes() {
    return RecipeRepository.getFavoriteRecipes();
  }

  //Проверить является ли рецепт isFavorite
  bool isFavorite(Recipe recipe) {
    return recipe.isFavorite;
  }

  //меняем состояние isFavorite
  Future<void> toggleFavorite(Recipe recipe) async {
    await RecipeRepository.toggleFavorite(recipe);
  }

  //Добавить рецепт
  Future<void> addRecipe(Recipe recipe) async {
    await RecipeRepository.addRecipe(recipe);
  }

  //Обновить существующий рецепт
  Future<void> updateRecipe(Recipe recipe) async {
    await RecipeRepository.updateRecipe(recipe);
  }

  //Получить Id для нового рецепта
  int getNextId() {
    return RecipeRepository.getNextId();
  }
}
