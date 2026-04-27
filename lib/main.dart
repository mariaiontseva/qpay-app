import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/backend_service.dart';
import 'services/companies_house_service.dart';
import 'services/formation_state.dart';

const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const String _chApiKey = String.fromEnvironment('CH_API_KEY');
const String _backendUrl = String.fromEnvironment('BACKEND_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Supabase only if both URL and anon key were injected at
  // compile time via --dart-define. Otherwise AuthService falls back to a
  // local mock that accepts the fixed code `123456`.
  SupabaseClient? supabaseClient;
  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
    supabaseClient = Supabase.instance.client;
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    QPayApp(
      authService: AuthService(supabaseClient),
      companiesHouseService: CompaniesHouseService(
        _chApiKey.isNotEmpty ? _chApiKey : null,
      ),
      backendService: BackendService(_backendUrl),
      formationState: FormationState(),
    ),
  );
}
