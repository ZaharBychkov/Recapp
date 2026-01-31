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

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = const [
      RecipeListScreen(),
      FridgeScreen(),
      FavoritesScreen(),
      ProfileScreen(),
    ];
  }

  Future<void> _openCreateRecipe(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateRecipeScreen(),
      ),
    );

    if (result == true) {
      setState(() {
        //RecipeListScreen сам перечитает данные из Hive
      });
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
