import 'package:hive/hive.dart';

part 'step.g.dart';

@HiveType(typeId: 1)
class RecipeStep extends HiveObject {
  @HiveField(0)
  final int stepNumber; 

  @HiveField(1)
  final String description; 

  @HiveField(2)
  final int timeInSeconds; 

  @HiveField(3)
  bool isCompleted; 

  RecipeStep({
    required this.stepNumber,
    required this.description, 
    required this.timeInSeconds,
    this.isCompleted = false,
  });
}