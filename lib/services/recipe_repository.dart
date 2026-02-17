import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/step.dart';
import '../domain/recipe_measurement_parser.dart';
import '../domain/unit_converter.dart';

class RecipeRepository {
  static const String _boxName = 'recipes';  //Имя бокса для хранения
  static Box<Recipe>? _box;
  static const _parser = RecipeMeasurementParser();
  static const _converter = UnitConverter();                 //Конвертер единиц измерения

  static Future<void> init() async {         //Инициализируем Hive асинхронно

    // Регистрируем адаптеры в нужном порядке: сначала вложенные, потом основной.
    // Hive.registerAdapter(IngredientAdapter()); // Вложенный
    // Hive.registerAdapter(RecipeStepAdapter()); // Вложенный
    // Hive.registerAdapter(RecipeAdapter());     // Основной
    _box = await Hive.openBox<Recipe>(_boxName); // Открываем бокс для хранения рецептов
    // По сути Hive ищет хранилище с именем 'recipes'.

    // Если база пустая, заполняем тестовыми данными.
    // Оператор ! означает логическое "не".
    if(_box!.isEmpty) {
      await _seedDefaultRecipes();
    }

    await _migrateMojibakeText();
    await _migrateRecipeMeasurements();
  }

  // Берем все избранные рецепты.
  static List<Recipe> getFavoriteRecipes() {
    return _box?.values.where((r) => r.isFavorite).toList() ?? [];
  }

  static ValueListenable<Box<Recipe>> recipesListenable() {
    if (_box == null) {
      throw Exception('RecipeRepository not initialized');
    }
    return _box!.listenable();
  }

  // Переключаем флаг избранного.
  static Future<void> toggleFavorite(Recipe recipe) async {
    recipe.isFavorite = !recipe.isFavorite;
    await recipe.save();
  }

  // Получить все рецепты.
  static List<Recipe> getAllRecipes() {
    return _box?.values.toList() ?? []; // Возвращаем список всех рецептов или пустой список.
  }

  // Добавить новый рецепт.
  static Future<void> addRecipe(Recipe recipe) async {
    await _box?.put(recipe.id, recipe); // Добавляем рецепт в бокс.
    debugPrint("Рецепт сохранен в Hive с ID: ${recipe.id}");
  }

  // Обновить существующий рецепт.
  static Future<void> updateRecipe(Recipe recipe) async {
    await _box?.put(recipe.id, recipe); // Обновляем рецепт по его ID.
    debugPrint("Рецепт обновлен в Hive с ID: ${recipe.id}");
  }

  // Удалить рецепт.
  static Future<void> deleteRecipe(int recipeId) async {
    try {
      debugPrint("Попытка удалить рецепт с ID: $recipeId");
      debugPrint("Количество рецептов до удаления: ${_box?.length}");
      
      await _box?.delete(recipeId);
      
      debugPrint("Количество рецептов после удаления: ${_box?.length}");
      debugPrint("Рецепт успешно удален из Hive с ID: $recipeId");
      
      // Принудительно сохраняем изменения.
      await _box?.flush();
      
    } catch (e) {
      debugPrint("Ошибка при удалении рецепта: $e");
      rethrow; // Перебрасываем ошибку дальше.
    }
  }

  // Получить следующий свободный ID.
  static int getNextId() {
    if (_box == null || _box!.isEmpty) return 1; 

    final maxId = _box!.values
      .map((r) => r.id)
      .reduce((a, b) => a > b ? a : b);
    return maxId + 1; 
  }
  // Берем все ID рецептов из box.values.
  // Находим максимальный через reduce и прибавляем 1.

  // Заполнение начальными рецептами (заглушка).
  static Future<void> _seedDefaultRecipes() async {
    final defaultRecipes = [
      Recipe(
        id: 1,
        title: "Лосось в соусе терияки",
        description: "Нежное филе лосося, приготовленное в ароматном соусе терияки с нотками имбиря и чеснока.",
        ingredients: [
          Ingredient(name: "Соевый соус", measurement: "8 ст. ложек"),
          Ingredient(name: "Вода", measurement: "6 ст. ложек"),
          Ingredient(name: "Мед", measurement: "3 ст. ложки"),
          Ingredient(name: "Коричневый сахар", measurement: "2 ст. ложки"),
          Ingredient(name: "Чеснок", measurement: "3 зубчика"),
          Ingredient(name: "Тертый свежий имбирь", measurement: "1 ст. ложка"),
          Ingredient(name: "Лимонный сок", measurement: "1.5 ст. ложки"),
          Ingredient(name: "Кукурузный крахмал", measurement: "1 ст. ложка"),
          Ingredient(name: "Растительное масло", measurement: "1 ч. ложка"),
          Ingredient(name: "Филе лосося", measurement: "680 г"),
          Ingredient(name: "Кунжут", measurement: "по вкусу"),
        ],
        prepTimeSeconds: 45 * 60,
        imagePath: "assets/Images/salmon_in_teriyaki_sauce.png",
        steps: [
          RecipeStep(
            stepNumber: 1,
            description: "В маленькой кастрюле соедините соевый соус, 6 столовых ложек воды, мёд, сахар, измельчённый чеснок, имбирь и лимонный сок.",
            timeInSeconds: 6 * 60,
          ),
          RecipeStep(
            stepNumber: 2,
            description: "Поставьте на средний огонь и, помешивая, доведите до лёгкого кипения.",
            timeInSeconds: 7 * 60,
          ),
          RecipeStep(
            stepNumber: 3,
            description: "Смешайте оставшуюся воду с крахмалом. Добавьте в кастрюлю и перемешайте.",
            timeInSeconds: 6 * 60,
          ),
          RecipeStep(
            stepNumber: 4,
            description: "Готовьте, непрерывно помешивая венчиком, 1 минуту. Снимите с огня и немного остудите.",
            timeInSeconds: 1 * 60,
          ),
          RecipeStep(
            stepNumber: 5,
            description: "Смажьте форму маслом и выложите туда рыбу. Полейте её соусом.",
            timeInSeconds: 6 * 60,
          ),
        ],
      ),
      Recipe(
        id: 2,
        title: "Бургер с двумя котлетами",
        description: "Сочный двойной бургер с хрустящими котлетами и свежими овощами.",
        ingredients: [
          Ingredient(name: "Булочка для бургера", measurement: "1 шт."),
          Ingredient(name: "Говяжья котлета", measurement: "2 шт. (по 100 г)"),
          Ingredient(name: "Салат", measurement: "50 г"),
          Ingredient(name: "Помидор", measurement: "1 шт."),
          Ingredient(name: "Лук", measurement: "1/2 шт."),
          Ingredient(name: "Сыр чеддер", measurement: "2 ломтика"),
          Ingredient(name: "Кетчуп", measurement: "1 ст. ложка"),
          Ingredient(name: "Горчица", measurement: "1 ч. ложка"),
          Ingredient(name: "Масло для жарки", measurement: "1 ст. ложка"),
        ],
        prepTimeSeconds: 60 * 60,
        imagePath: "assets/Images/burger_with_two_cutlets.png",
        steps: [
          RecipeStep(
            stepNumber: 1,
            description: "Разогрейте сковороду на среднем огне и слегка смажьте маслом.",
            timeInSeconds: 2 * 60,
          ),
          RecipeStep(
            stepNumber: 2,
            description: "Обжарьте котлеты по 4 минуты с каждой стороны до золотистой корочки.",
            timeInSeconds: 8 * 60,
          ),
          RecipeStep(
            stepNumber: 3,
            description: "Добавьте ломтики сыра на котлеты за 1 минуту до готовности.",
            timeInSeconds: 1 * 60,
          ),
          RecipeStep(
            stepNumber: 4,
            description: "Поджарьте булочки на сухой сковороде до хруста.",
            timeInSeconds: 2 * 60,
          ),
          RecipeStep(
            stepNumber: 5,
            description: "Соберите бургер: булочка, кетчуп, котлеты, овощи, вторая булочка.",
            timeInSeconds: 3 * 60,
          ),
        ],
      ),
      Recipe(
        id: 3,
        title: "Стейк из говядины по-грузински с кукурузой",
        description: "Классический грузинский стейк с пряными специями и сливочным соусом.",
        ingredients: [
          Ingredient(name: "Говядина", measurement: "400 г"),
          Ingredient(name: "Лук", measurement: "1 шт."),
          Ingredient(name: "Чеснок", measurement: "2 зубчика"),
          Ingredient(name: "Сливочное масло", measurement: "50 г"),
          Ingredient(name: "Сливки", measurement: "100 мл"),
          Ingredient(name: "Хмели-сунели", measurement: "1 ч. ложка"),
          Ingredient(name: "Соль", measurement: "по вкусу"),
          Ingredient(name: "Перец", measurement: "по вкусу"),
          Ingredient(name: "Масло для жарки", measurement: "2 ст. ложки"),
        ],
        prepTimeSeconds: 75 * 60,
        imagePath: "assets/Images/georgian_beef_steak.png",
        steps: [
          RecipeStep(
            stepNumber: 1,
            description: "Нарежьте мясо на толстые стейки толщиной 2-3 см.",
            timeInSeconds: 5 * 60,
          ),
          RecipeStep(
            stepNumber: 2,
            description: "Посолите, поперчите и посыпьте хмели-сунели.",
            timeInSeconds: 2 * 60,
          ),
          RecipeStep(
            stepNumber: 3,
            description: "Разогрейте сковороду с маслом на сильном огне.",
            timeInSeconds: 3 * 60,
          ),
          RecipeStep(
            stepNumber: 4,
            description: "Обжарьте стейки по 4 минуты с каждой стороны.",
            timeInSeconds: 8 * 60,
          ),
          RecipeStep(
            stepNumber: 5,
            description: "Добавьте сливочное масло, чеснок и лук. Полейте стейки соусом.",
            timeInSeconds: 5 * 60,
          ),
        ],
      ),
      Recipe(
        id: 4,
        title: "Пицца Маргарита домашняя",
        description: "Традиционная итальянская пицца с томатами, моцареллой и базиликом.",
        ingredients: [
          Ingredient(name: "Тесто для пиццы", measurement: "200 г"),
          Ingredient(name: "Моцарелла", measurement: "150 г"),
          Ingredient(name: "Помидоры", measurement: "100 г"),
          Ingredient(name: "Базилик", measurement: "5-6 листьев"),
          Ingredient(name: "Оливковое масло", measurement: "1 ст. ложка"),
          Ingredient(name: "Соль", measurement: "щепотка"),
          Ingredient(name: "Томатный соус", measurement: "3 ст. ложки"),
        ],
        prepTimeSeconds: 25 * 60,
        imagePath: "assets/Images/homemade_pizza_margarita.png",
        steps: [
          RecipeStep(
            stepNumber: 1,
            description: "Разогрейте духовку до 220°C.",
            timeInSeconds: 10 * 60,
          ),
          RecipeStep(
            stepNumber: 2,
            description: "Раскатайте тесто в круглую форму.",
            timeInSeconds: 5 * 60,
          ),
          RecipeStep(
            stepNumber: 3,
            description: "Смажьте тесто томатным соусом и посыпьте тёртой моцареллой.",
            timeInSeconds: 3 * 60,
          ),
          RecipeStep(
            stepNumber: 4,
            description: "Выпекайте в духовке 12 минут до золотистой корочки.",
            timeInSeconds: 12 * 60,
          ),
          RecipeStep(
            stepNumber: 5,
            description: "Выньте из духовки и украсьте свежим базиликом.",
            timeInSeconds: 1 * 60,
          ),
        ],
      ),
      Recipe(
        id: 5,
        title: "Паста с морепродуктами",
        description: "Ароматная паста с креветками, мидиями и сливочным соусом.",
        ingredients: [
          Ingredient(name: "Спагетти", measurement: "200 г"),
          Ingredient(name: "Креветки", measurement: "150 г"),
          Ingredient(name: "Мидии", measurement: "100 г"),
          Ingredient(name: "Сливки", measurement: "150 мл"),
          Ingredient(name: "Чеснок", measurement: "2 зубчика"),
          Ingredient(name: "Петрушка", measurement: "1 ст. ложка"),
          Ingredient(name: "Оливковое масло", measurement: "2 ст. ложки"),
          Ingredient(name: "Соль", measurement: "по вкусу"),
          Ingredient(name: "Перец", measurement: "по вкусу"),
        ],
        prepTimeSeconds: 25 * 60,
        imagePath: "assets/Images/pasta_with_seafood.png",
        steps: [
          RecipeStep(
            stepNumber: 1,
            description: "Отварите спагетти в подсоленной воде до состояния al dente.",
            timeInSeconds: 10 * 60,
          ),
          RecipeStep(
            stepNumber: 2,
            description: "Разогрейте сковороду с оливковым маслом.",
            timeInSeconds: 2 * 60,
          ),
          RecipeStep(
            stepNumber: 3,
            description: "Обжарьте чеснок до аромата, добавьте морепродукты.",
            timeInSeconds: 5 * 60,
          ),
          RecipeStep(
            stepNumber: 4,
            description: "Влейте сливки, посолите, поперчите. Протушите 3 минуты.",
            timeInSeconds: 3 * 60,
          ),
          RecipeStep(
            stepNumber: 5,
            description: "Добавьте пасту и перемешайте. Украсьте петрушкой.",
            timeInSeconds: 2 * 60,
          ),
        ],
      ),
      Recipe(
        id: 6,
        title: "Поке боул с сыром тофу",
        description: "Свежий гавайский салат с тунцом, авокадо и сырным акцентом.",
        ingredients: [
          Ingredient(name: "Тунец", measurement: "200 г"),
          Ingredient(name: "Авокадо", measurement: "1 шт."),
          Ingredient(name: "Рис", measurement: "150 г"),
          Ingredient(name: "Соевый соус", measurement: "2 ст. ложки"),
          Ingredient(name: "Сыр фета", measurement: "50 г"),
          Ingredient(name: "Огурец", measurement: "1/2 шт."),
          Ingredient(name: "Кунжутное масло", measurement: "1 ч. ложка"),
          Ingredient(name: "Соль", measurement: "по вкусу"),
        ],
        prepTimeSeconds: 30 * 60,
        imagePath: "assets/Images/poke_bowl_with_cheese.png",
        steps: [
          RecipeStep(
            stepNumber: 1,
            description: "Отварите рис до готовности и остудите.",
            timeInSeconds: 15 * 60,
          ),
          RecipeStep(
            stepNumber: 2,
            description: "Нарежьте тунец, авокадо и огурец крупными кубиками.",
            timeInSeconds: 5 * 60,
          ),
          RecipeStep(
            stepNumber: 3,
            description: "Смешайте соевый соус с кунжутным маслом.",
            timeInSeconds: 2 * 60,
          ),
          RecipeStep(
            stepNumber: 4,
            description: "Выложите рис в миску, сверху добавьте ингредиенты.",
            timeInSeconds: 3 * 60,
          ),
          RecipeStep(
            stepNumber: 5,
            description: "Полейте соусом и посыпьте сыром фета.",
            timeInSeconds: 1 * 60,
          ),
        ],
      ),
      Recipe(
        id: 7,
        title: "Тосты с голубикой и бананом",
        description: "Сладкий и полезный тост с фруктами и мёдом.",
        ingredients: [
          Ingredient(name: "Хлеб для тостов", measurement: "2 ломтика"),
          Ingredient(name: "Банан", measurement: "1 шт."),
          Ingredient(name: "Черника", measurement: "50 г"),
          Ingredient(name: "Мёд", measurement: "1 ст. ложка"),
          Ingredient(name: "Сливочное масло", measurement: "1 ч. ложка"),
          Ingredient(name: "Кокосовая стружка", measurement: "1 ч. ложка (по желанию)"),
        ],
        prepTimeSeconds: 45 * 60,
        imagePath: "assets/Images/toast_with_blueberries_and_banana.png",
        steps: [
          RecipeStep(
            stepNumber: 1,
            description: "Поджарьте хлеб в тостере до хруста.",
            timeInSeconds: 3 * 60,
          ),
          RecipeStep(
            stepNumber: 2,
            description: "Намажьте тосты сливочным маслом.",
            timeInSeconds: 1 * 60,
          ),
          RecipeStep(
            stepNumber: 3,
            description: "Нарежьте банан кружочками и выложите на тосты.",
            timeInSeconds: 2 * 60,
          ),
          RecipeStep(
            stepNumber: 4,
            description: "Посыпьте черникой и полейте мёдом.",
            timeInSeconds: 1 * 60,
          ),
          RecipeStep(
            stepNumber: 5,
            description: "Посыпьте кокосовой стружкой по желанию.",
            timeInSeconds: 1 * 60,
          ),
        ],
      ),
    ];

    for (final recipe in defaultRecipes) {
      await _box?.put(recipe.id, recipe);
    }
  }
  static Future<void> _migrateRecipeMeasurements() async {
    if (_box == null) return;

    final recipes = _box!.values.toList();

    for (final recipe in recipes) {
      var changed = false;
      final migrated = <Ingredient>[];

      for (final ing in recipe.ingredients) {
        final parsed = _parser.parse(ing.measurement);
        if (parsed == null) {
          migrated.add(
            Ingredient(
              name: ing.name,
              measurement: '1 г',
            ),
          );
          changed = true;
          continue;
        }

        final canonical = parsed.toCanonicalString(_converter);
        migrated.add(
          Ingredient(
            name: ing.name,
            measurement: canonical,
          ),
        );
        if (canonical != ing.measurement) {
          changed = true;
        }
      }

      if (changed) {
        recipe.ingredients = migrated;
        await _box!.put(recipe.id, recipe);
      }
    }
  }

  static Future<void> _migrateMojibakeText() async {
    if (_box == null) return;

    final recipes = _box!.values.toList();

    for (final recipe in recipes) {
      var changed = false;

      final fixedTitle = _fixMojibake(recipe.title);
      if (fixedTitle != recipe.title) {
        recipe.title = fixedTitle;
        changed = true;
      }

      final fixedDescription = _fixMojibake(recipe.description);
      if (fixedDescription != recipe.description) {
        recipe.description = fixedDescription;
        changed = true;
      }

      final fixedIngredients = <Ingredient>[];
      for (final ingredient in recipe.ingredients) {
        final fixedName = _fixMojibake(ingredient.name);
        final fixedMeasurement = _fixMojibake(ingredient.measurement);
        fixedIngredients.add(
          Ingredient(
            name: fixedName,
            measurement: fixedMeasurement,
          ),
        );

        if (fixedName != ingredient.name || fixedMeasurement != ingredient.measurement) {
          changed = true;
        }
      }

      final fixedSteps = <RecipeStep>[];
      for (final step in recipe.steps) {
        final fixedStepDescription = _fixMojibake(step.description);
        fixedSteps.add(
          RecipeStep(
            stepNumber: step.stepNumber,
            description: fixedStepDescription,
            timeInSeconds: step.timeInSeconds,
            isCompleted: step.isCompleted,
          ),
        );

        if (fixedStepDescription != step.description) {
          changed = true;
        }
      }

      if (changed) {
        recipe.ingredients = fixedIngredients;
        recipe.steps = fixedSteps;
        await _box!.put(recipe.id, recipe);
      }
    }
  }

  static String _fixMojibake(String value) {
    const r = '\u0420';
    const s = '\u0421';
    final sourceMarkers = value.split('').where((ch) => ch == r || ch == s).length;
    if (sourceMarkers < 2) return value;

    try {
      final bytes = <int>[];
      for (final rune in value.runes) {
        final cpByte = _unicodeToCp1251Byte(rune);
        if (cpByte == null) return value;
        bytes.add(cpByte);
      }

      final fixed = utf8.decode(bytes);
      final fixedMarkers = fixed.split('').where((ch) => ch == r || ch == s).length;
      if (fixedMarkers < sourceMarkers) {
        return fixed;
      }
    } catch (_) {
      return value;
    }

    return value;
  }

  static int? _unicodeToCp1251Byte(int rune) {
    if (rune >= 0x00 && rune <= 0x7F) return rune;
    if (rune >= 0x0410 && rune <= 0x044F) return rune - 0x350;

    const map = <int, int>{
      0x0402: 0x80,
      0x0403: 0x81,
      0x201A: 0x82,
      0x0453: 0x83,
      0x201E: 0x84,
      0x2026: 0x85,
      0x2020: 0x86,
      0x2021: 0x87,
      0x20AC: 0x88,
      0x2030: 0x89,
      0x0409: 0x8A,
      0x2039: 0x8B,
      0x040A: 0x8C,
      0x040C: 0x8D,
      0x040B: 0x8E,
      0x040F: 0x8F,
      0x0452: 0x90,
      0x2018: 0x91,
      0x2019: 0x92,
      0x201C: 0x93,
      0x201D: 0x94,
      0x2022: 0x95,
      0x2013: 0x96,
      0x2014: 0x97,
      0x2122: 0x99,
      0x0459: 0x9A,
      0x203A: 0x9B,
      0x045A: 0x9C,
      0x045C: 0x9D,
      0x045B: 0x9E,
      0x045F: 0x9F,
      0x00A0: 0xA0,
      0x040E: 0xA1,
      0x045E: 0xA2,
      0x0408: 0xA3,
      0x00A4: 0xA4,
      0x0490: 0xA5,
      0x00A6: 0xA6,
      0x00A7: 0xA7,
      0x0401: 0xA8,
      0x00A9: 0xA9,
      0x0404: 0xAA,
      0x00AB: 0xAB,
      0x00AC: 0xAC,
      0x00AD: 0xAD,
      0x00AE: 0xAE,
      0x0407: 0xAF,
      0x00B0: 0xB0,
      0x00B1: 0xB1,
      0x0406: 0xB2,
      0x0456: 0xB3,
      0x0491: 0xB4,
      0x00B5: 0xB5,
      0x00B6: 0xB6,
      0x00B7: 0xB7,
      0x0451: 0xB8,
      0x2116: 0xB9,
      0x0454: 0xBA,
      0x00BB: 0xBB,
      0x0458: 0xBC,
      0x0405: 0xBD,
      0x0455: 0xBE,
      0x0457: 0xBF,
    };

    return map[rune];
  }
}

