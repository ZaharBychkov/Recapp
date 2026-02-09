import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "avpetrov"; // Имя пользователя (можно заменить на реальное)

  void _showAvatarAction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              _actionItem(
                text: 'Сфотографировать',
                onTap: () {},
              ),
              const Divider(height: 1),
              _actionItem(
                text: 'Выбрать из альбома',
                onTap: () {},
              ),
              const Divider(height: 1),
              _actionItem(
                text: 'Удалить',
                textColor: Colors.red,
                onTap: () {},
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.01),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ],
          ),
        );
      },
    );
  }


  Widget _actionItem({
    required String text,
    required VoidCallback onTap,
    Color textColor = Colors.black,
}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            )
          )
        )
      )
    );
  }

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
                    _showAvatarAction(context);
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