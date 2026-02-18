import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image, instantiateImageCodec;

import 'app_bootstrap.dart';
import 'main_screen.dart';
import 'painters/text_image_painter.dart';
import 'registration_screen.dart';
import 'services/user_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _minSplashDuration = Duration(milliseconds: 900);

  ui.Image? _backgroundImage;
  late final DateTime _shownAt;

  bool _isExiting = false;
  bool _slideOut = false;
  bool _completed = false;
  Widget _nextScreen = const SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    _shownAt = DateTime.now();
    _prepare();
  }

  Future<void> _prepare() async {
    await Future.wait([
      _loadBackgroundImage(),
      AppBootstrap.start(),
    ]);

    if (!mounted) return;

    final user = UserRepository.getCurrentUser();
    setState(() {
      _nextScreen = user == null ? const RegistrationScreen() : const MainScreen();
    });

    final elapsed = DateTime.now().difference(_shownAt);
    if (elapsed < _minSplashDuration) {
      await Future<void>.delayed(_minSplashDuration - elapsed);
    }

    if (!mounted) return;
    await _startExit();
  }

  Future<void> _loadBackgroundImage() async {
    try {
      final byteData = await rootBundle.load('assets/Images/food_background.png');
      final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() => _backgroundImage = frame.image);
      }
    } catch (e, st) {
      debugPrint('Failed to load splash background image: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _startExit() async {
    if (_isExiting) return;
    _isExiting = true;

    setState(() {
      _slideOut = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 390));
    if (!mounted) return;

    setState(() {
      _completed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _nextScreen,
          if (!_completed)
            AnimatedSlide(
              offset: _slideOut ? const Offset(0, -1.2) : Offset.zero,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeInOutCubic,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2ECC71),
                      Color(0xFF165932),
                    ],
                  ),
                ),
                child: Center(child: _buildContent(size)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(Size size) {
    if (_backgroundImage == null) {
      return Text(
        'OTUS\nFOOD',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.17,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      );
    }

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
