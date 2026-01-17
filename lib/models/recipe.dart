import 'ingredient.dart';
import 'step.dart';

class Recipe {
  int id;
  String title;
  String description;
  List<Ingredient> ingredients;
  int prepTimeSeconds;
  String imagePath;
  List<Step> steps;

  Recipe(this.id, this.title, this.description, this.ingredients, this.prepTimeSeconds, this.imagePath, this.steps);
}