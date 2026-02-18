import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:otus_food_app/registration_screen.dart';

void main() {
  testWidgets('Registration screen renders smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));

    expect(find.text('Otus.Food'), findsOneWidget);
    expect(find.text('Регистрация'), findsOneWidget);
    expect(find.text('Вход'), findsOneWidget);
    expect(find.text('Рецепты'), findsOneWidget);
  });
}
