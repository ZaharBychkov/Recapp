import 'package:flutter/material.dart';
import '../widgets/png_icon.dart'; // Импортируем новый виджет

class LoginScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2ECC71),

      //Ниже тело экрана, для размещения всего содержимого
      body: SafeArea(//Обеспечивает отступы от системных элементов
        child: Padding(//Добавляет внутренние отступы по сторонам, чтобы контент не прилипал к краям
          padding: const EdgeInsets.all(24.0),
          child: Column(//Вертикальный контеинер
            crossAxisAlignment: CrossAxisAlignment.center,//Выравнивание содержимого по центру
            mainAxisAlignment: MainAxisAlignment.center,//Вырваниваине содержимого по центру по вертикали (занимает всю высоту)
            children: [//Заголовок Otus.Food - крупный белый жирный
              Text(
                'Otus.Food',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,//Жирноность
                    ),
              ),
              const SizedBox(height: 40.0),//Отступы между заголовком и полями вода

              Form(//Контейнер для полей ввода, позволяте управлять их состоянием(валидация, сброс)
                key: formKey,//Привязываю ключ формы, чтобы можно было вызывать validate() или reset()
                child: Column(
                  children: [
                    TextFormField(//Поле ввода логина
                      controller: loginController,//Привязываем контроллер - он будет хранить текущее значение поля
                      decoration: InputDecoration(//Создаем внешний вид поля

                        prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),//Иконка внутри поля ввода

                        hintText: 'логин',//Подсказака для пользователя где вводить текст
                        hintStyle: TextStyle(color: Colors.grey[600]),//Цвет текста подсказки

                        fillColor: Colors.white,//Фон поля ввода
                        filled: true,//Заливаем белый фон

                        //Закругляем углы
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        focusedBorder: OutlineInputBorder(//Ставим цвет, когда пользователь начнет что - то вводить
                          borderSide: BorderSide(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10.0),
                        )

                      ),
                    ),//Закрываем поле ввода логина

                    const SizedBox(height: 16.0),//Создаю отступ между полями

                    TextFormField(//Поле ввода пороля
                      controller: passwordController,//Контреллер хранит значения поля пароля
                      obscureText: true,//Маскировка (звездачки вместо текста)
                      decoration: InputDecoration(//Создаем внешний вид

                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),//Иконка замка

                        hintText: 'пароль',// Подсказка для пользователя
                        hintStyle: TextStyle(color: Colors.grey[600]),

                        fillColor: Colors.white,//Белый фон поля
                        filled: true,//Включаю заливку

                        border: OutlineInputBorder(//Закругляю угол
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        focusedBorder: OutlineInputBorder(//Убираем тень и границу при фокусе
                          borderSide: BorderSide(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10.0),
                        )

                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80.0,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: PngIcon( // Используем PngIcon вместо SvgIcon
                  asset: 'assets/Icons/pizza_grey.png', // Изменяем расширение на .png
                  size: 32.0,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: PngIcon( // Используем PngIcon вместо SvgIcon
                  asset: 'assets/Icons/person_green.png', // Изменяем расширение на .png
                  size: 32.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}