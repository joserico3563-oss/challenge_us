import 'package:flutter_test/flutter_test.dart';

import 'package:challenge_us/app/app.dart';

void main() {
  testWidgets('Muestra la pantalla de bienvenida', (WidgetTester tester) async {
    await tester.pumpWidget(const ChallengeUsApp());
    await tester.pump();

    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(find.text('Continuar con correo'), findsOneWidget);
  });
}