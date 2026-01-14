import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../painters/text_image_painter.dart';
import 'dart:ui' as ui show Image, instantiateImageCodec;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});                    //const для повышения производительности

  @override
  State<SplashScreen> createState() => _SplashScreenState(); //Создаем стэйт типа SplashScreen под названием _SplashScreenState()
}

class _SplashScreenState extends State<SplashScreen> { //Создаем класс внутри стейта для работы с состоянием
  ui.Image? _backgroundImage;                         // Сюда сохраним декодированное изображение после загрузки т.е. изображение из пикселей
  String? _errorMessage;                              // Переменная для хранения сообщения об ошибке (если загрузка провалится)

  @override
  void initState() {                                  // Вызывается один раз при создании состояния
    super.initState();                                // Вызов родителя через super чтобы Flutter понял как ему инициализировать
    _loadBackgroundImage();                           // Запускаем асинхронную загрузку изображения сразу
  }

  Future<void> _loadBackgroundImage() async {   //Сама ассинхронная загрузка
    try {
      final byteData = await rootBundle.load('assets/Images/food_background.png');
      // Получаем байты изображения из assets (один раз!)

      final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
      // Создаём декодер для работы с этими байтами

      final frame = await codec.getNextFrame();       // Декодируем первый кадр (раз у нас готовое изображение, то единственный кадр)

      if (mounted) {                                  // Проверяем, что виджет всё ещё существует, пользователь до сих пор на странице
        setState(() => _backgroundImage = frame.image); // Сохраняем изображение и вызываем перерисовку
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Не удалось загрузить фоновую картинку');
        // Сохраняем сообщение об ошибке и обновляем UI
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);          //Получаю размер экрана

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(              // const здесь — хорошая оптимизация
          gradient: LinearGradient(                   //градиент слева серху в право вниз
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF66FF99),
              Color(0xFF2ECC71),
            ],
          ),
        ),
        child: Center(
          child: _buildContent(size),                 // Выносим логику виджета в отдельный метод
        ),
      ),
    );
  }

  Widget _buildContent(Size size) {                    //Вывод ошибки
    if (_errorMessage != null) {                      // Если произошла ошибка при загрузке
      return Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red, fontSize: 18),
      );
    }

    if (_backgroundImage == null) {                   // Ещё не загрузилось изображение
      return const SizedBox(                          // Компактный индикатор, а не на весь экран
        width: 48,
        height: 48,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    }

    // Когда изображение уже загружено — показываем основной контент
    return SizedBox(
      width: size.width * 0.66,
      height: size.height * 0.305,
      child: Stack(
        fit: StackFit.expand,                         //Дети стека растягиваются на всю область SizedBox
        alignment: Alignment.center,
        children: [
          Image.asset(                                // Простой и надёжный способ показать картинку
            'assets/Images/food_background.png',
            fit: BoxFit.contain,                      // Рястягиваем все изображение
          ),

          CustomPaint(
            painter: TextImagePainter(
              text: 'OTUS\nFOOD',
              fontSize: size.width * 0.21,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              image: _backgroundImage!,               // Используем уже готовое декодированное изображение для отрисовки
            ),
          ),
        ],
      ),
    );
  }
}