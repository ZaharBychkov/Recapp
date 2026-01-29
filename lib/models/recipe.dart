import 'package:hive/hive.dart';
import 'ingredient.dart';
import 'step.dart';

part 'recipe.g.dart';

@HiveType(typeId: 2)
class Recipe extends HiveObject {
  
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final List<Ingredient> ingredients;
  
  @HiveField(4)
  final int prepTimeSeconds;
  
  @HiveField(5)
  final String imagePath;
  
  @HiveField(6)
  final List<RecipeStep> steps; 

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.prepTimeSeconds,
    required this.imagePath,
    required this.steps,
  });
}