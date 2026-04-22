import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qpay_app/app.dart';

void main() {
  testWidgets('SignupScreen is the initial route', (tester) async {
    await tester.pumpWidget(const QPayApp());
    await tester.pumpAndSettle();
    expect(find.text('Business banking, next level.'), findsOneWidget);
    expect(find.text('Send verification code'), findsOneWidget);
  });

  testWidgets('CTA from signup navigates to intent picker', (tester) async {
    await tester.pumpWidget(const QPayApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send verification code'));
    await tester.pumpAndSettle();
    expect(find.textContaining('What brings you'), findsOneWidget);
    expect(find.text('Form a new Ltd company'), findsOneWidget);
  });
}
