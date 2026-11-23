import 'package:flutter_test/flutter_test.dart';

import 'package:challenge_us/app/app.dart';

void main() {
  testWidgets('Muestra la pantalla de bienvenida', (WidgetTester tester) async {
    await tester.pumpWidget(const ChallengeUsApp());
    await tester.pump();

    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(find.text('Continuar con correo'), findsOneWidget);
  });

  testWidgets('La hoja de correo permite cambiar a registro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChallengeUsApp());
    await tester.pump();

    await tester.tap(find.text('Continuar con correo'));
    await tester.pumpAndSettle();

    expect(find.text('Entra con tu correo'), findsOneWidget);

    await tester.tap(find.text('¿Primera vez? Crea tu cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.text('Tu nombre'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });
}
