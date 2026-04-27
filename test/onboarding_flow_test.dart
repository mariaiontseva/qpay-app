import 'package:flutter_test/flutter_test.dart';
import 'package:qpay_app/app.dart';
import 'package:qpay_app/services/auth_service.dart';
import 'package:qpay_app/services/backend_service.dart';
import 'package:qpay_app/services/companies_house_service.dart';

void main() {
  testWidgets('SignupScreen is the initial route', (tester) async {
    await tester.pumpWidget(QPayApp(
      authService: AuthService(null),
      companiesHouseService: CompaniesHouseService(null),
      backendService: BackendService(''),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Business banking, next level.'), findsOneWidget);
    expect(find.text('Send verification code'), findsOneWidget);
  });

  testWidgets('CTA from signup navigates to intent picker', (tester) async {
    await tester.pumpWidget(QPayApp(
      authService: AuthService(null),
      companiesHouseService: CompaniesHouseService(null),
      backendService: BackendService(''),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send verification code'));
    await tester.pumpAndSettle();
    expect(find.textContaining('What brings you'), findsOneWidget);
    expect(find.text('Form a new Ltd company'), findsOneWidget);
  });
}
