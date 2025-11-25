import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_financas/main.dart';

void main() {
  testWidgets('App inicia sem erros', (WidgetTester tester) async {
    // Inicializa o app
    await tester.pumpWidget(const MyApp());

    // Verifica se algum texto principal da tela de login está presente
    expect(find.text('Bem-vinda ao Finanças+'), findsOneWidget);

    // Verifica se o botão "Entrar" está presente
    expect(find.text('Entrar'), findsOneWidget);

    // Verifica se os campos de e-mail e senha estão presentes
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
