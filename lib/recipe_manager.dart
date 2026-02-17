import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/recipe_repository.dart';
import 'models/recipe.dart';

class RecipeManager {
  static final RecipeManager _instance = RecipeManager._internal();
  factory RecipeManager() => _instance;
  RecipeManager._internal();

  List<Recipe> getRecipes() {
    return RecipeRepository.getAllRecipes();
  }

  List<Recipe> getFavoriteRecipes() {
    return RecipeRepository.getFavoriteRecipes();
  }

  ValueListenable<Box<Recipe>> recipesListenable() {
    return RecipeRepository.recipesListenable();
  }

  bool isFavorite(Recipe recipe) {
    return recipe.isFavorite;
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    await RecipeRepository.toggleFavorite(recipe);
  }

  Future<void> addRecipe(Recipe recipe) async {
    await RecipeRepository.addRecipe(recipe);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await RecipeRepository.updateRecipe(recipe);
  }

  Future<void> deleteRecipe(int recipeId) async {
    await RecipeRepository.deleteRecipe(recipeId);
  }

  int getNextId() {
    return RecipeRepository.getNextId();
  }
}
