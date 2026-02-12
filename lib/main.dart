import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/user.dart';
import 'models/recipe.dart';
import 'models/ingredient.dart';
import 'models/step.dart';

import 'services/recipe_repository.dart';
import 'services/user_repository.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Регистрируем ВСЕ адаптеры
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(RecipeStepAdapter());
  Hive.registerAdapter(RecipeAdapter());

  // Инициализация репозиториев
  await UserRepository.init();
  await RecipeRepository.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otus Food App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainScreen(),
    );
  }
}