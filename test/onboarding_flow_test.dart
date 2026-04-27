import 'package:flutter_test/flutter_test.dart';
import 'package:qpay_app/app.dart';
import 'package:qpay_app/services/auth_service.dart';
import 'package:qpay_app/services/backend_service.dart';
import 'package:qpay_app/services/companies_house_service.dart';
import 'package:qpay_app/services/formation_state.dart';

QPayApp _buildApp() => QPayApp(
      authService: AuthService(null),
      companiesHouseService: CompaniesHouseService(null),
      backendService: BackendService(''),
      formationState: FormationState(),
    );

void main() {
  testWidgets('Signup is the initial route', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();
    expect(find.text("What's your\nname?"), findsOneWidget);
  });
}
