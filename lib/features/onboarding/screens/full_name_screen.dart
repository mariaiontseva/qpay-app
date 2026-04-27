import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_screen.dart';
import '../../../services/auth_provider.dart';

/// Post-verification profile step, shown only to first-time users.
/// Saves the name into Supabase user metadata then lands on `/intent`.
class FullNameScreen extends StatefulWidget {
  const FullNameScreen({super.key});

  @override
  State<FullNameScreen> createState() => _FullNameScreenState();
}

class _FullNameScreenState extends State<FullNameScreen> {
  final TextEditingController _name = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _ok => _name.text.trim().length >= 2 && !_busy;

  Future<void> _save() async {
    if (!_ok) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthProvider.of(context).updateProfile(name: _name.text.trim());
      if (!mounted) return;
      context.go('/intent');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not save name. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return QScreen(
      ambient: true,
      bottom: QBottomBar(
        child: QButton(
          label: _busy ? 'Saving…' : 'Continue',
          onPressed: _ok ? _save : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: QPayTokens.s7),
          const QHeader(
            title: 'What should\nwe call you?',
            subtitle: 'Your full name goes on company paperwork, so make it official.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: QField(
              label: 'Full name',
              controller: _name,
              placeholder: 'First and last',
              autofillHint: AutofillHints.name,
              keyboardType: TextInputType.name,
              inputFormatters: [
                LengthLimitingTextInputFormatter(64),
              ],
              autofocus: true,
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Text(
                _error!,
                style: QPayType.heroSub.copyWith(
                  color: QPayTokens.alert,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}
