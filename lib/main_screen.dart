import 'package:flutter/material.dart';

import 'create_screen.dart';
import 'favorites_screen.dart';
import 'fridge_screen.dart';
import 'profile_screen.dart';
import 'recipe_list_screen_universal.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final GlobalKey _recipeListKey = GlobalKey();
  final GlobalKey _fridgeKey = GlobalKey();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RecipeListScreen(
        key: _recipeListKey,
        isLoggedIn: true,
        onAddRecipePressed: _openCreateRecipe,
      ),
      FridgeScreen(key: _fridgeKey),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];
  }

  Future<void> _openCreateRecipe() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateRecipeScreen()),
    );
    if (!mounted) return;

    if (result == true && _recipeListKey.currentState != null) {
      (_recipeListKey.currentState as dynamic).refreshRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
          _buildTab(0, Icons.local_pizza_rounded),
          _buildTab(1, Icons.kitchen_rounded),
          _buildTab(2, Icons.favorite_rounded),
          _buildTab(3, Icons.person_rounded),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData iconData) {
    final isActive = _currentIndex == index;
    const activeColor = Color(0xFF2ECC71);
    const inactiveColor = Color(0xFF9E9E9E);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (index == 1 && _fridgeKey.currentState != null) {
            (_fridgeKey.currentState as dynamic).refreshFridge();
          }

          setState(() {
            _currentIndex = index;
          });
        },
        child: Center(
          child: Icon(
            iconData,
            size: 28,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
      ),
    );
  }
}
