import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'registration_screen.dart';
import 'recipe_list_screen.dart';
import 'recipe_detail_screen.dart';
import 'recipe_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeManager = RecipeManager();
    final firstRecipe = recipeManager.getRecipes()[0];


    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
         primarySwatch: Colors.green,
         scaffoldBackgroundColor: Colors.white,
      ),
      // home: Scaffold(//home - начальный экран приложения
      //   body: RecipeList(recipes: RecipeManager().getRecipes()),//Основное содержимое
      // )
          home: RecipeListScreen(),
    );
  }
}