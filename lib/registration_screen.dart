import 'package:flutter/material.dart';

import 'guest_recipe_list_screen.dart';
import 'main_screen.dart';
import 'models/user.dart';
import 'services/user_repository.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final login = loginController.text.trim();
    if (login.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите логин')),
      );
      return;
    }

    final user = User(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: login,
      password: '',
      login: login,
    );

    await UserRepository.saveUser(user);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const activeColor = Color(0xFF2ECC71);
    const inactiveColor = Color(0xFF9E9E9E);
    final bottomBarHeight = (size.height * 0.08).clamp(64.0, 84.0);
    final bottomIconSize = (size.width * 0.056).clamp(18.0, 24.0);
    final bottomTextSize = (size.width * 0.0234).clamp(9.0, 11.0);

    return Scaffold(
      backgroundColor: const Color(0xFF2ECC71),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.056),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Otus.Food',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.0654,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: size.height * 0.043),
                      _buildInput(
                        context: context,
                        controller: loginController,
                        hint: 'логин',
                        iconData: Icons.person,
                      ),
                      SizedBox(height: size.height * 0.017),
                      _buildInput(
                        context: context,
                        controller: passwordController,
                        hint: 'пароль',
                        iconData: Icons.lock,
                        obscureText: true,
                      ),
                      SizedBox(height: size.height * 0.017),
                      _buildInput(
                        context: context,
                        controller: confirmPasswordController,
                        hint: 'пароль еще раз',
                        iconData: Icons.lock,
                        obscureText: true,
                      ),
                      SizedBox(height: size.height * 0.026),
                      SizedBox(
                        width: size.width * 0.542,
                        height: size.height * 0.0517,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF125932),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Регистрация',
                            style: TextStyle(
                              fontSize: size.width * 0.0374,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: size.height * 0.02,
              child: Center(
                child: Text(
                  'Войти в приложение',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.0374,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: bottomBarHeight,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const GuestRecipeListScreen()),
                  );
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_pizza_rounded,
                        size: bottomIconSize,
                        color: inactiveColor,
                      ),
                      Text(
                        'Рецепты',
                        style: TextStyle(
                          color: inactiveColor,
                          fontSize: bottomTextSize,
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
                onTap: () {},
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: bottomIconSize,
                        color: activeColor,
                      ),
                      Text(
                        'Вход',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: bottomTextSize,
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

  Widget _buildInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData iconData,
    bool obscureText = false,
  }) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.542,
      height: size.height * 0.0517,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(
            iconData,
            size: size.width * 0.056,
            color: const Color(0xFF9E9E9E),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: const Color(0xFFC2C2C2),
                  fontSize: size.width * 0.0374,
                  fontFamily: 'Roboto',
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
