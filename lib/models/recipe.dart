import 'package:hive/hive.dart';
import 'ingredient.dart';
import 'step.dart';

part 'recipe.g.dart';

@HiveType(typeId: 2)
class Recipe extends HiveObject {
  
  @HiveField(0)
  int id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  List<Ingredient> ingredients;
  
  @HiveField(4)
  int prepTimeSeconds;
  
  @HiveField(5)
  String imagePath;
  
  @HiveField(6)
  List<RecipeStep> steps;

  @HiveField(7)
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.prepTimeSeconds,
    required this.imagePath,
    required this.steps,
    this.isFavorite = false,
  });
}