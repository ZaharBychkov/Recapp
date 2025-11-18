import 'package:flutter/material.dart';
import '../widgets/png_icon.dart'; // Импортируем новый виджет

class RegistrationScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2ECC71),

      body: SafeArea(//Тело экрана
        child: Padding(//Обеспечиваем отсутпы от системных элементов
          padding: EdgeInsets.symmetric(//Внутреннием отступы по сторонам от краев
            horizontal: MediaQuery.of(context).size.width * 0.056, //Примерный процент отступов исходя из шаблона Figma
            vertical: MediaQuery.of(context).size.width * 0.052,
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, //Выравнивание по второстепенной оси
              mainAxisAlignment: MainAxisAlignment.center, //Выравнивание с верха, а не с центра
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),//Отступ сверху
                Text(
                  'Otus.Food',
                  style:TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.0654,
                    fontWeight: FontWeight.w400, //Жирность исходя из макета
                    fontFamily: 'Roboto', //Шрифт из макета
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.043),
                Form(
                    key: formKey,//Приязка ключа формы
                    child: Column(
                      children: [
                        Container( //Поле ввода логина
                            width: MediaQuery.of(context).size.width * 0.542,
                            height: MediaQuery.of(context).size.height * 0.0517,
                            decoration: BoxDecoration(
                              color: Colors.white, //Белый фон
                              borderRadius: BorderRadius.circular(10),//Статичный радиус
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 8),//Отступ в начале этой строки
                                Image.asset(
                                  'assets/Icons/person_grey.png',
                                  width: MediaQuery.of(context).size.width * 0.056,
                                  height: MediaQuery.of(context).size.width * 0.056,
                                ),
                                SizedBox(width: 8),// Отступ от иконки выше
                                Expanded( // Занимаем оставшееся место под текст
                                  child: TextField( // Поле ввода
                                    controller: loginController, // Привязываем контроллер
                                    decoration: InputDecoration( // Оформление поля
                                      hintText: 'логин', // Текст подсказка
                                      hintStyle: TextStyle( // Стиль текста подсказки
                                        color: Color(0xFFC2C2C2),
                                        fontSize: MediaQuery.of(context).size.width * 0.0374,
                                        fontFamily: 'Roboto',
                                      ),
                                      border: InputBorder.none, // Убираем рамку
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.017),

                        Container(//Поле ввода пороля
                            width: MediaQuery.of(context).size.width * 0.542,
                            height: MediaQuery.of(context).size.height * 0.0517,
                            decoration: BoxDecoration(
                              color:Colors.white,
                              borderRadius: BorderRadius.circular(10),//
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 8),

                                Image.asset(
                                  'assets/Icons/lock_grey.png',
                                  width: MediaQuery.of(context).size.width * 0.056,
                                  height: MediaQuery.of(context).size.width * 0.056,
                                ),
                                SizedBox(width: 8),
                                Expanded( // Занимаем оставшееся место под текст
                                  child: TextField( // Поле ввода
                                    controller: passwordController, // Привязываем контроллер
                                    obscureText: true, // Маскируем пароль
                                    decoration: InputDecoration( // Оформление поля
                                      hintText: 'пароль', // Текст подсказка
                                      hintStyle: TextStyle( // Стиль текста подсказки
                                        color: Color(0xFFC2C2C2),
                                        fontSize: MediaQuery.of(context).size.width * 0.0374,
                                        fontFamily: 'Roboto',
                                      ),
                                      border: InputBorder.none, // Убираем рамку
                                    ),
                                  ),
                                ),
                              ],
                            )
                        )
                      ],
                    )
                ), //Завершение блока двух полей

                SizedBox(height: MediaQuery.of(context).size.height * 0.017),

                Container(//Поле ввода "пароль еще раз"
                  width: MediaQuery.of(context).size.width * 0.542,
                  height: MediaQuery.of(context).size.height * 0.0517,
                  decoration: BoxDecoration(
                    color:Colors.white,
                    borderRadius: BorderRadius.circular(10),//
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 8),

                      Image.asset(
                        'assets/Icons/lock_grey.png',
                        width: MediaQuery.of(context).size.width * 0.056,
                        height: MediaQuery.of(context).size.height * 0.056,
                      ),
                      SizedBox(width: 8),
                      Expanded( // Занимаем оставшееся место под текст
                        child: TextField( // Поле ввода
                          controller: confirmPasswordController, // Привязываем контроллер
                          obscureText: true, // Маскируем пароль
                          decoration: InputDecoration( // Оформление поля
                            hintText: 'пароль еще раз', // Текст подсказка
                            hintStyle: TextStyle( // Стиль текста подсказки
                              color: Color(0xFFC2C2C2),
                              fontSize: MediaQuery.of(context).size.width * 0.0374,
                              fontFamily: 'Roboto',
                            ),
                            border: InputBorder.none, // Убираем рамку
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.026),

                Container(//Кнопка регистрации
                  width: MediaQuery.of(context).size.width * 0.542,
                  height: MediaQuery.of(context).size.height * 0.0517,
                  decoration: BoxDecoration(
                    color: Color(0xFF125932),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      'Регистрация',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.0374,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),//Конец блока регистрации

                SizedBox(height: MediaQuery.of(context).size.height * 0.026),
                Spacer(),//Заполнить все пространство между кнопкой и нижней понелью

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
      ),//Завершение основного экрана

      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(//Занимаем все доступное пространство внутри Row
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, //Центрирование по вертикали
                  children: [
                  PngIcon(
                    asset: 'assets/Icons/pizza_grey.png',
                    size: MediaQuery.of(context).size.width * 0.056,
                  ),
                  Text(
                    'Рецепты',
                    style: TextStyle(
                      color: Color(0xFFC2C2C2),
                      fontSize: MediaQuery.of(context).size.width * 0.0234,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      )
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
                    color: Color(0xFF2ECC71),
                      fontSize: MediaQuery.of(context).size.width * 0.0234,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      )
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
}