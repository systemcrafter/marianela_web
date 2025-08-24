import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marianela_web/main.dart';

void main() {
  testWidgets('Renderiza la app sin crashear', (WidgetTester tester) async {
    await tester.pumpWidget(const MarianelaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
