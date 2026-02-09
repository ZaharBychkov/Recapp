import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';
import 'models/recipe.dart';
import 'recipe_manager.dart';
import 'fridge_screen.dart';
import 'recipe_list_screen_universal.dart';
import 'profile_screen.dart';
import 'registration_screen.dart';
import 'create_screen.dart';
import 'recipe_repository.dart';
import 'main_screen.dart';
import 'package:hive/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(RecipeStepAdapter());
  Hive.registerAdapter(RecipeAdapter());

  await RecipeRepository.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Берём первый рецепт из менеджера
    final recipes = RecipeManager().getRecipes();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MainScreen(),
    );
  }
}