import 'package:flutter/material.dart';

import 'recipe_list_screen_universal.dart';
import 'fridge_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'create_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  /*
   * GlobalKey - это ключ, который позволяет получить доступ к State виджета
   * 
   * ПОЧЕМУ МЫ ИСПОЛЬЗУЕМ GlobalKey:
   * IndexedStack сохраняет состояние виджетов, но нам нужно вызывать методы
   * конкретного виджета (RecipeListScreen) из другого виджета (MainScreen)
   * 
   * GlobalKey.currentState дает доступ к State объекта виджета
   */
  final GlobalKey _recipeListKey = GlobalKey();
  final GlobalKey _fridgeKey = GlobalKey();
  final GlobalKey _favoritesKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  /*
   * Метод для открытия экрана создания рецепта
   * 
   * ПРОБЛЕМА БЫЛА ЗДЕСЬ:
   * Раньше этот метод просто вызывал setState() с комментарием
   * "//RecipeListScreen сам перечитает данные из Hive"
   * 
   * НО ЭТО НЕ РАБОТАЛО, потому что:
   * 1. setState() в MainScreen не влияет на RecipeListScreen
   * 2. RecipeListScreen не вызывал initState() повторно (из-за GlobalKey)
   * 3. Список рецептов оставался старым
   */
  Future<void> _openCreateRecipe(BuildContext context) async {
    /*
     * Открываем экран создания рецепта и ждем результат
     * CreateRecipeScreen вернет true, если рецепт был успешно создан
     */
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateRecipeScreen(),  // Без параметра = режим создания
      ),
    );

    /*
     * ЕСЛИ РЕЦЕПТ БЫЛ СОЗДАН (result == true):
     * Нам нужно обновить список в RecipeListScreen
     * 
     * ПОЧЕМУ ИМЕННО ТАК:
     * 1. _recipeListKey.currentState - получаем доступ к State RecipeListScreen
     * 2. as dynamic - приводим к типу dynamic для вызова метода
     * 3. refreshRecipes() - вызываем наш новый метод для обновления списка
     * 
     * БЕЗ ЭТОГО: Новые рецепты сохранялись в Hive, но UI не обновлялся
     */
    if (result == true) {
      // Обновляем список рецептов через GlobalKey
      if (_recipeListKey.currentState != null) {
        (_recipeListKey.currentState as dynamic).refreshRecipes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /*
     * Создаем экраны с ключами для сохранения состояния в IndexedStack
     * 
     * ВАЖНО ПОНИМАТЬ:
     * 1. IndexedStack - это виджет, который показывает ОДИН экран из списка,
     *    но ДЕРЖИТ ВСЕ экраны в памяти (не уничтожает их)
     * 2. GlobalKey - позволяет получить доступ к конкретному экрану
     * 3. Из-за IndexedStack initState() вызывается только ОДИН РАЗ
     * 
     * ПОЭТОМУ НАМ НУЖЕН GlobalKey + refreshRecipes()
     */
    final screens = [
      RecipeListScreen(
        key: _recipeListKey,  // Ключ для доступа к этому виджету
        isLoggedIn: true,    // Явно указываем что пользователь залогинен
        onAddRecipePressed: () => _openCreateRecipe(context),  // Callback для кнопки "+"
      ),
      FridgeScreen(key: _fridgeKey),
      FavoritesScreen(key: _favoritesKey),
      ProfileScreen(key: _profileKey),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab(0, 'pizza'),
          _buildTab(1, 'fridge'),
          _buildTab(2, 'heart'),
          _buildTab(3, 'person'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String iconName) {
    final isActive = _currentIndex == index;

    final assetPath = 'assets/Icons/${iconName}_${isActive ? 'green' : 'grey'}.png';

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Center(
          child: Image.asset(
            assetPath,
            width: 26,
            height: 26,
            color: isActive ? const Color(0xFF2ECC71) : Colors.black54,
          ),
        ),
      ),
    );
  }
}
