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

  @override
  void initState() {                                  // Вызывается один раз при создании состояния
    super.initState();                                // Вызов родителя через super чтобы Flutter понял как ему инициализировать
    _loadBackgroundImage();                           // Запускаем асинхронную загрузку изображения сразу
  }

  Future<void> _loadBackgroundImage() async {
    try {
      final byteData = await rootBundle.load('assets/Images/food_background.png');
      // Получаем байты изображения из assets (один раз!)
      final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
      // Создаём декодер для работы с этими байтами
      final frame = await codec.getNextFrame();       // Декодируем первый кадр (раз у нас готовое изображение, то единственный кадр)
      if (mounted) {                                  // Проверяем, что виджет всё ещё существует, пользователь до сих пор на странице
        setState(() => _backgroundImage = frame.image); // Сохраняем изображение и вызываем перерисовку
      }
    } catch (e, st) {
      debugPrint('Не удалось загрузить фоновую картинку: $e');
      debugPrintStack(stackTrace: st);
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
              Color(0xFF2ECC71), // Светлый зелёный — #2ECC71
              Color(0xFF165932), // Тёмный зелёный — #165932
            ],
          ),
        ),
        child: Center(
          child: _buildContent(size),                 // Выносим логику виджета в отдельный метод
        ),
      ),
    );
  }

  Widget _buildContent(Size size) {

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
      child: CustomPaint(
        painter: TextImagePainter(
          text: 'OTUS\nFOOD',
          fontSize: size.width * 0.23,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
          image: _backgroundImage!,
        ),
      ),
    );

  }
}

