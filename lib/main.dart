import 'package:flutter/material.dart';
import 'package:otus_food_app/recipe_manager.dart';
import 'package:otus_food_app/recipe_list.dart';
import 'login_sceen.dart';
import 'registration_sceen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {//переопределяем build для построения виджета
    return MaterialApp(//Возврощаем корневой виджет
      title: 'Flutter Demo',//Устанавливаем название приложения в заголовке
      theme: ThemeData(//Определяет цвета, шрифты и стили
         primarySwatch: Colors.green,//Установка основного цвета
         scaffoldBackgroundColor: Colors.white,//Установка фона для Scaffold
      ),
      // home: Scaffold(//home - начальный экран приложения
      //   body: RecipeList(recipes: RecipeManager().getRecipes()),//Основное содержимое
      // )
          home: LoginScreen(),
    );
  }
}