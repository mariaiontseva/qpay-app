import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/tokens.dart';
import '../../design_system/typography.dart';
import '../../design_system/widgets/q_bottom_bar.dart';
import '../../design_system/widgets/q_button.dart';
import '../../design_system/widgets/q_screen.dart';
import '../../services/auth_provider.dart';
import '../../services/formation_state.dart';

/// Account / profile screen reachable from the avatar icon on the Home
/// tab. Shows the current user + company on top, then sign-out and a
/// destructive delete-account action under their own card.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final auth = AuthProvider.of(context);

    final name = (auth.currentName ?? s.userName).trim();
    final email = (auth.currentEmail ?? s.userEmail).trim();
    final companyName = s.filedCompanyName == '—' ? '—' : s.filedCompanyName;

    return QScreen(
      bottom: QBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QButton(
              label: 'Sign out',
              kind: QButtonKind.secondary,
              onPressed: () => _confirmSignOut(context),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _confirmDelete(context),
              child: Text(
                'Delete account',
                style: QPayType.statusLineStrong
                    .copyWith(color: QPayTokens.alert),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BackBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Text('Account', style: QPayType.heroTitle),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _IdentityCard(
              name: name.isEmpty ? '—' : name,
              email: email.isEmpty ? '—' : email,
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 6, 24, 0),
            child: Text(
              'COMPANY',
              style: QPayType.fieldLabel.copyWith(letterSpacing: 1.4),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _Card(
              children: [
                _Row(label: 'Name', value: companyName),
                _Row(label: 'Company number', value: '15837421'),
                _Row(
                  label: 'Jurisdiction',
                  value: s.useQPayOffice
                      ? 'England and Wales'
                      : (s.ownAddress?.jurisdiction.label ??
                          'England and Wales'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 6, 24, 0),
            child: Text(
              'IDENTITY',
              style: QPayType.fieldLabel.copyWith(letterSpacing: 1.4),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _Card(
              children: [
                _Row(
                  label: 'Personal code',
                  value: 'XYZ123ABCD',
                  mono: true,
                ),
                const _Row(label: 'Verification', value: '✓ Verified'),
              ],
            ),
          ),
          const SizedBox(height: QPayTokens.s7),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final auth = AuthProvider.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: QPayTokens.cardBase,
        title: const Text('Sign out?'),
        content: const Text(
          "We'll keep your data. Sign in with the same email to come back.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await auth.signOut();
    if (!context.mounted) return;
    context.go('/signup');
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final auth = AuthProvider.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: QPayTokens.cardBase,
        title: const Text('Delete this account?'),
        content: const Text(
          "This removes your QPay login. The Companies House record stays "
          "as it's a public statutory filing — only Companies House can "
          "remove that.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: QPayTokens.alert),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await auth.deleteAccount();
    if (!context.mounted) return;
    context.go('/signup');
  }
}

class _IdentityCard extends StatelessWidget {
  final String name;
  final String email;
  const _IdentityCard({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: QPayTokens.canvas,
              shape: BoxShape.circle,
              border: Border.all(color: QPayTokens.border, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: QPayType.optionTitle.copyWith(
                fontSize: 18,
                color: QPayTokens.ink,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: QPayType.optionTitle),
                const SizedBox(height: 2),
                Text(email, style: QPayType.heroSub),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '·';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.border, width: 1),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: QPayTokens.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  const _Row({
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(child: Text(label, style: QPayType.heroSub)),
          Text(
            value,
            style: (mono ? QPayType.progressNum : QPayType.optionTitle)
                .copyWith(color: QPayTokens.ink, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(QPayTokens.s5, 10, QPayTokens.s6, 0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(QPayTokens.rMd),
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: QPayTokens.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
