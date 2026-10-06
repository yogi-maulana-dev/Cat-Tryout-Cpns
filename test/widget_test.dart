import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:try_out_bayog/main.dart';

void main() {
  testWidgets('App membangun tanpa error', (WidgetTester tester) async {
    await tester.pumpWidget(const TryOutBayogApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
