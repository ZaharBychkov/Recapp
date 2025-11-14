import 'package:flutter/material.dart';
import '../widgets/svg_icon.dart';

class LoginScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>(); //Глобальный ключ виджета в дереве
  final loginController = TextEditingController();//Хранение текста
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container( //body отвечает за основное пространсо экрана, помещаю Container в него
        color: Colors.green, //Устанавливаю контеинеру зеленый цвет
          child: const Center(
            child: Text(
              'Login Form',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
      ),
      bottomNavigationBar: Container(//Оборачиваю нижнюю панель в контеинер
        height: 80.0,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(//Распределяет пространство между "братьями" пропорционально их Flex
              child: Center(//Внтруи этого пространства центрируем следующию картинку
                child:SvgIcon(
                  asset: 'assets/Icons/pizza_icon.svg',
                  size: 32.0,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(//Добовляю второй элемент и в этом моменте код делит все пространство на половину т.к. появился второй элемент
              child: Center(
                child: SvgIcon(
                  asset: 'assets/Icons/person_icon.svg',
                  size: 32.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

