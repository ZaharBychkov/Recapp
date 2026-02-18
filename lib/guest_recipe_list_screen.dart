import 'package:flutter/material.dart';

import 'recipe_list_screen_universal.dart';
import 'registration_screen.dart';

class GuestRecipeListScreen extends StatelessWidget {
  const GuestRecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF2ECC71);
    const inactiveColor = Color(0xFF9E9E9E);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: const RecipeListScreen(
        isLoggedIn: false,
      ),
      bottomNavigationBar: Container(
        height: size.height * 0.08,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_pizza_rounded,
                        size: size.width * 0.056,
                        color: activeColor,
                      ),
                      Text(
                        'Рецепты',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: size.width * 0.0234,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                  );
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: size.width * 0.056,
                        color: inactiveColor,
                      ),
                      Text(
                        'Вход',
                        style: TextStyle(
                          color: inactiveColor,
                          fontSize: size.width * 0.0234,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
