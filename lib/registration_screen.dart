import 'package:flutter/material.dart';

import 'widgets/png_icon.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF2ECC71),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.056,
                vertical: MediaQuery.of(context).size.width * 0.052,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                      Text(
                        'Otus.Food',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.0654,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.043),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            _buildInput(
                              context: context,
                              controller: loginController,
                              hint: 'логин',
                              iconAsset: 'assets/Icons/person_grey.png',
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.017),
                            _buildInput(
                              context: context,
                              controller: passwordController,
                              hint: 'пароль',
                              iconAsset: 'assets/Icons/lock_grey.png',
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.017),
                      _buildInput(
                        context: context,
                        controller: confirmPasswordController,
                        hint: 'пароль еще раз',
                        iconAsset: 'assets/Icons/lock_grey.png',
                        obscureText: true,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.026),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.542,
                        height: MediaQuery.of(context).size.height * 0.0517,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF125932),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Регистрация',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.0374,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.026),
                      const Spacer(),
                      Text(
                        'Войти в приложение',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.0374,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
                    PngIcon(
                      asset: 'assets/Icons/pizza_grey.png',
                      size: MediaQuery.of(context).size.width * 0.056,
                    ),
                    Text(
                      'Рецепты',
                      style: TextStyle(
                        color: const Color(0xFFC2C2C2),
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
                    PngIcon(
                      asset: 'assets/Icons/person_green.png',
                      size: MediaQuery.of(context).size.width * 0.056,
                    ),
                    Text(
                      'Вход',
                      style: TextStyle(
                        color: const Color(0xFF2ECC71),
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

  Widget _buildInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required String iconAsset,
    bool obscureText = false,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.542,
      height: MediaQuery.of(context).size.height * 0.0517,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Image.asset(
            iconAsset,
            width: MediaQuery.of(context).size.width * 0.056,
            height: MediaQuery.of(context).size.width * 0.056,
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
                  fontSize: MediaQuery.of(context).size.width * 0.0374,
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
