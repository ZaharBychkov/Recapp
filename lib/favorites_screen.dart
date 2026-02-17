import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'recipe_manager.dart';
import 'models/recipe.dart';
import 'utils/time_formatter.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.0374,
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.026),
              Expanded(
                child: ValueListenableBuilder<Box<Recipe>>(
                  valueListenable: RecipeManager().recipesListenable(),
                  builder: (context, box, _) {
                    final favorites = box.values.where((r) => r.isFavorite).toList();

                    if (favorites.isEmpty) {
                      return const Center(
                        child: Text(
                          'В избранном пока пусто ❤️',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final recipe = favorites[index];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailScreen(
                                  recipe: recipe,
                                  isLoggedIn: true,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.017,
                            ),
                            height: MediaQuery.of(context).size.height * 0.147,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 20,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                    child: Image.asset(
                                      recipe.imagePath,
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                                Expanded(
                                  flex: 33,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: MediaQuery.of(context).size.height * 0.025,
                                        left: 0,
                                        right: 0,
                                        child: Text(
                                          recipe.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).size.width * 0.06,
                                            fontWeight: FontWeight.w600,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: MediaQuery.of(context).size.height * 0.025,
                                        left: 0,
                                        child: Row(
                                          children: [
                                            Image.asset('assets/Icons/clock.png', width: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              formatTime(recipe.prepTimeSeconds),
                                              style: TextStyle(
                                                color: const Color(0xFF2ECC71),
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
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
