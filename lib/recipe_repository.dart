import 'package:hive_flutter/hive_flutter.dart';
import 'models/recipe.dart';
import 'models/ingredient.dart';
import 'models/step.dart';

class RecipeRepository {
  static const String _boxName = 'recipes';  //Имя коробки для хранения 
  static Box<Recipe>? _box;                 //Коробка с рецептами

  static Future<void> init() async {         //Инициализируем ассинхронно Hive
      
    await Hive.initFlutter();             //Ждем пока загрзится пржде чем начать работу

    //Регистрируем адаптеры (в нужно порядке: сначала вложенные ), они уже сгенерированы 
    Hive.registerAdapter(IngredientAdapter()); //Вложенный 
    Hive.registerAdapter(RecipeStepAdapter()); //Вложенные
    Hive.registerAdapter(RecipeAdapter());     //Основной

    _box = await Hive.openBox<Recipe>(_boxName); //Открываем коробку для хранения рецептов
    //Посути Hive ищет папку с названием 'recipes' для этого и нужно имя для

    //Если база пустая - заполняем тестовыми данными 
    //Если ! слева значит логическое Не, если справа - не null
    if(_box!.isEmpty) {
      await _seedDefaultRecipes();
    }
  }

  //Берем все рецепты
  static List<Recipe> getFavoriteRecipes() {
    return _box?.values.where((r) => r.isFavorite).toList() ?? [];
  }

  //Конроллер для изменения состояния isFavorite
  static Future<void> toggleFavorite(Recipe recipe) async {
    recipe.isFavorite = !recipe.isFavorite;
    await recipe.save();
  }

  //Получить все рецепты
  static List<Recipe> getAllRecipes() {
    return _box?.values.toList() ?? []; //Возвращаем список всех рецептов или пустой список
  }

  //Добавить новый рецепт 
  static Future<void> addRecipe(Recipe recipe) async {
    await _box?.put(recipe.id, recipe); //Добавляем рецепт в коробку, которая возможно пустая
    print("Рецепт сохранен в Hive с ID: ${recipe.id}");
  }

  //Обновить существующий рецепт
  static Future<void> updateRecipe(Recipe recipe) async {
    await _box?.put(recipe.id, recipe); //Обновляем рецепт по его ID
    print("Рецепт обновлен в Hive с ID: ${recipe.id}");
  }

  //Удалить рецепт
  static Future<void> deleteRecipe(int recipeId) async {
    await _box?.delete(recipeId); //Удаляем рецепт по ID
    print("Рецепт удален из Hive с ID: $recipeId");
  }

  //Получить следующий свободный ID 
  static int getNextId() {
    if (_box == null || _box!.isEmpty) return 1; 

    final maxId = _box!.values
      .map((r) => r.id)
      .reduce((a, b) => a > b ? a : b);
    return maxId + 1; 
  }
  //По сути берем тут box.values т.е. Recipe(0), Recipe(1) и т.д. 
  //И возвращаем r.id т.е. int geiId(Recipe r) {return r.id} 
  //Но проще через лямбла написать (r) => r.id  
  //Итог у нас есть все Id Recipe от Recipe(0) до Recipe(максимального)
  //reduce - есди a > b то верни а, иначе врени b 
  //Но проще написать a > b ? a : b (: - и есть вот это иначе true (а) : false (b)) 
  //Сам reduce = свернуть весь список элементов в одно значение по определенно условию  
  //В конце возвращаем это максимальное Id и прибовляем 1 получаем новое Id для нового рецепта   

  //Заполнение начальными рецептами (заглушка)
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
      await _box?.add(recipe);
    }
  }
}