import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user.dart';
import 'models/recipe.dart';
import 'models/ingredient.dart';
import 'models/step.dart';
import 'services/recipe_repository.dart';
import 'services/user_repository.dart';
import 'repositories/fridge_repository.dart';
import 'repositories/history_repository.dart';
import 'main_screen.dart';
import 'registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(RecipeStepAdapter());
  Hive.registerAdapter(RecipeAdapter());

  await UserRepository.init();
  await RecipeRepository.init();
  await FridgeRepository.init();
  await HistoryRepository.init();

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
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate();

  @override
  Widget build(BuildContext context) {
    final user = UserRepository.getCurrentUser();
    if (user == null) {
      return const RegistrationScreen();
    }
    return const MainScreen();
  }
}
