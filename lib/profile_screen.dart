import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "avpetrov"; // Имя пользователя (можно заменить на реальное)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Светло-серый фон
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              Center(
                child: GestureDetector(
                  onTap: () {
                    // Можно добавить функцию для изменения аватара
                    print("Нажали на аватар");
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF165932), width: 3.5),
                      color: Colors.white, // Фоновый цвет
                    ),
                    child: ClipOval(                      //Обрезаем изображение строго по кругу
                      child: Padding(                    //Отступ между границей круга и изображением
                        padding: EdgeInsets.all(20),    //Контроль размера изображения
                        child: Image.asset(
                          'assets/Icons/empty_avatar.png',
                          fit: BoxFit.contain,                 //Изображение масштабируется пропорционально, полносью помещаясь внутрь
                        )
                      )
                    ),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              // Блок с логином
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD9D9D9)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Логин',
                      style: TextStyle(
                        color: Color(0xff165932),
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      username, // Имя пользователя
                      style: TextStyle(
                        color: Color(0xFF2ECC71), // Зелёный цвет
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              // Кнопка "Выход"
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD9D9D9)),
                ),
                child: Center(
                  child: Text(
                    'Выход',
                    style: TextStyle(
                      color: Colors.red, // Красный цвет
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}