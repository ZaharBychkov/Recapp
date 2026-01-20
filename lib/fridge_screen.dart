import 'package:flutter/material.dart';
import 'models/recipe.dart';
import 'recipe_manager.dart';
import 'models/ingredient.dart';
import '../utils/time_formatter.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  int _selectedIndex = 0;
  List<Recipe> recommendedRecipes = [];

  // Список ингредиентов в холодильнике
  List<Ingredient> fridgeIngredients = [
    // Для "Лосось в соусе терияки"
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
    // Для "Пицца Маргарита домашняя"
    Ingredient(name: "Тесто для пиццы", measurement: "200 г"),
    Ingredient(name: "Моцарелла", measurement: "150 г"),
    Ingredient(name: "Помидоры", measurement: "100 г"),
    Ingredient(name: "Базилик", measurement: "5-6 листьев"),
    Ingredient(name: "Оливковое масло", measurement: "1 ст. ложка"),
    Ingredient(name: "Соль", measurement: "щепотка"),
    Ingredient(name: "Томатный соус", measurement: "3 ст. ложки"),

    // Для "Паста с морепродуктами"
    Ingredient(name: "Спагетти", measurement: "200 г"),
    Ingredient(name: "Креветки", measurement: "150 г"),
    Ingredient(name: "Мидии", measurement: "100 г"),
    Ingredient(name: "Сливки", measurement: "150 мл"),
    Ingredient(name: "Чеснок", measurement: "2 зубчика"),
    Ingredient(name: "Петрушка", measurement: "1 ст. ложка"),
    Ingredient(name: "Оливковое масло", measurement: "2 ст. ложки"),
    Ingredient(name: "Соль", measurement: "по вкусу"),
    Ingredient(name: "Перец", measurement: "по вкусу"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'В холодильнике',
                        style: TextStyle(
                          color: Color(0xFF165932),
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      ...fridgeIngredients.map((ingredient) => _buildItem(ingredient.name, ingredient.measurement)).toList(),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: () {
                        _compareWithRecipes();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2ECC71),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Рекомендовать рецепты',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                if (recommendedRecipes.isNotEmpty)
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                if (recommendedRecipes.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: recommendedRecipes.asMap().entries.map((entry) {
                        int index = entry.key;
                        Recipe recipe = entry.value;
                        return Container(
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.017,   //Отступ 0.017 от высоты экрана
                          ),
                          width: MediaQuery.of(context).size.width * 0.925,        //Размеры контейнера
                          height: MediaQuery.of(context).size.height * 0.147,
                          decoration: BoxDecoration(                               //Закгругление контейнеров
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,                                    //Белый фон контейнера
                          ),
                          child: Row(                                               //Создаем ряд в контейнере с двумя элементами Expanded для изображения
                            children: [                                             //и Expanded - Column для текста с иконкой и временм
                              Expanded(
                                flex: 20,
                                child: ClipRRect(                                   //Обрезаем изобраежние также как и сам контейнер чтобы небыло отсрых уголов
                                  borderRadius: BorderRadius.only(                  //only - значит нужно конкретно указать углы для скругления, в отличии от circular
                                    topLeft: Radius.circular(10),                   //Верхний левый
                                    bottomLeft: Radius.circular(10),                //Левый нижний
                                  ),
                                  child: Image.asset(                                 //Загружаем изображение
                                    recipe.imagePath,                                 //Берем изображение по пути
                                    fit: BoxFit.cover,                                //Заполняем весь контейнер обрезаем то что не влазит
                                    height: double.infinity,                          //Занимаем всю высоту  контейнера
                                  ),
                                ),
                              ),

                              SizedBox(width: MediaQuery.of(context).size.width * 0.03), //Отступ между изображением и текстом

                              // Текстовая часть
                              //Железобетонно ставим все элементы
                              Expanded(
                                flex: 33,
                                child: Stack(
                                  children: [
                                    Positioned(                                                 //Точно позиционируем дочерние элементы в стеке
                                      top: MediaQuery.of(context).size.height * 0.025,          //Отступ сверху
                                      left: 0,
                                      right: 0,
                                      child: Padding(                                            //Добавление внутренних отступов
                                        padding: const EdgeInsets.only(right: 4),               //Отступ только справа 12 пикселей
                                        child: Text(
                                          recipe.title,
                                          maxLines: 2,                                            //Максимальное количество строк
                                          overflow: TextOverflow.ellipsis,                        //Если текст не помещается - добавить многоточие
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).size.width * 0.06,
                                            fontWeight: FontWeight.w600,
                                            height: 1.0,
                                            leadingDistribution: TextLeadingDistribution.even,     //Распределение свообдного места между строками
                                          ),
                                        ),
                                      ),
                                    ),

                                    Positioned(                                                     //Второй элемент
                                      bottom: MediaQuery.of(context).size.height * 0.025,           //Отступ снизу
                                      left: 0,
                                      child: Row(
                                        children: [
                                          Image.asset('assets/Icons/clock.png', width: MediaQuery.of(context).size.width * 0.05),
                                          const SizedBox(width: 8),
                                          Text(
                                            formatTime(recipe.prepTimeSeconds),
                                            style: TextStyle(
                                              color: Color(0xFF2ECC71),
                                              fontSize: MediaQuery.of(context).size.width * 0.04,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Icons/pizza_grey.png',
                      width: MediaQuery.of(context).size.width * 0.056,
                    ),
                    Text(
                      'Рецепты',
                      style: TextStyle(
                        color: _selectedIndex == 0 ? Color(0xFF2ECC71) : Color(0xFFC2C2C2),
                        fontSize: MediaQuery.of(context).size.width * 0.0234,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Icons/fridge_green.png',
                      width: MediaQuery.of(context).size.width * 0.056,
                    ),
                    Text(
                      'Холодильник',
                      style: TextStyle(
                        color: _selectedIndex == 1 ? Color(0xFF2ECC71) : Color(0xFFC2C2C2),
                        fontSize: MediaQuery.of(context).size.width * 0.0234,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Icons/heart_grey.png',
                      width: MediaQuery.of(context).size.width * 0.056,
                    ),
                    Text(
                      'Избранное',
                      style: TextStyle(
                        color: _selectedIndex == 2 ? Color(0xFF2ECC71) : Color(0xFFC2C2C2),
                        fontSize: MediaQuery.of(context).size.width * 0.0234,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Icons/person_grey.png',
                      width: MediaQuery.of(context).size.width * 0.056,
                    ),
                    Text(
                      'Профиль',
                      style: TextStyle(
                        color: _selectedIndex == 3 ? Color(0xFF2ECC71) : Color(0xFFC2C2C2),
                        fontSize: MediaQuery.of(context).size.width * 0.0234,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String name, String quantity) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.014,
            height: MediaQuery.of(context).size.width * 0.02,
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            name,
            style: TextStyle(
              color: Colors.black,
              fontSize: MediaQuery.of(context).size.width * 0.035,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Text(
            quantity,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: MediaQuery.of(context).size.width * 0.033,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _compareWithRecipes() {
    final recipeManager = RecipeManager();
    final allRecipes = recipeManager.getRecipes();

    List<Recipe> matchingRecipes = [];

    for (final recipe in allRecipes) {
      bool allIngredientsAvailable = true;

      for(final ingredient in recipe.ingredients) {
        if (!fridgeIngredients.any((fridgeIng) =>
        fridgeIng.name.trim().toLowerCase() == ingredient.name.trim().toLowerCase()
        )) {
          allIngredientsAvailable = false;
          break;
        }
      }

      if (allIngredientsAvailable) {
        print("Рецепт '${recipe.title}' можно приготовить - все ингредиенты есть!");
        matchingRecipes.add(recipe);
      } else {
        print("Рецепт '${recipe.title}' нельзя приготовить - не хватает ингредиентов");
      }
    }

    setState(() {
      recommendedRecipes = matchingRecipes;
    });
  }
}