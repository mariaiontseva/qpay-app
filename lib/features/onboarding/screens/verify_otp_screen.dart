import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_screen.dart';
import '../../../services/auth_provider.dart';

/// Post-signup OTP screen. Eight-digit email code → Supabase verifyOTP.
/// Name is now collected on signup, so we go straight to /intent. The
/// name (if any) is persisted into Supabase user metadata right after
/// the OTP exchange.
class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String name;

  const VerifyOtpScreen({super.key, required this.email, this.name = ''});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _busy = false;
  String? _error;
  int _resendIn = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    _code.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendIn = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendIn <= 1) {
        t.cancel();
        setState(() => _resendIn = 0);
      } else {
        setState(() => _resendIn -= 1);
      }
    });
  }

  static const int _codeLength = 8;

  bool get _codeOk => _code.text.length == _codeLength;

  Future<void> _verify() async {
    if (!_codeOk || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = AuthProvider.of(context);
      await auth.verifyOtp(email: widget.email, code: _code.text);
      // Persist the name captured on signup, if any. Failures here are
      // non-fatal — the user can still proceed.
      if (widget.name.trim().isNotEmpty) {
        try {
          await auth.updateProfile(name: widget.name.trim());
        } catch (_) {}
      }
      if (!mounted) return;
      context.go('/intent');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_resendIn > 0) return;
    try {
      await AuthProvider.of(context).resendOtp(widget.email);
      _startResendTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code resent')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not resend right now.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return QScreen(
      bottom: QBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QButton(
              label: _busy ? 'Verifying…' : 'Verify',
              onPressed: _codeOk && !_busy ? _verify : null,
            ),
            const SizedBox(height: QPayTokens.s4),
            Center(
              child: _resendIn > 0
                  ? Text(
                      'Resend code in ${_resendIn}s',
                      style: QPayType.heroSub.copyWith(
                        color: QPayTokens.ink3,
                        fontSize: 13,
                      ),
                    )
                  : TextButton(
                      onPressed: _resend,
                      style: TextButton.styleFrom(
                        foregroundColor: QPayTokens.ink,
                        padding: const EdgeInsets.symmetric(
                          horizontal: QPayTokens.s5,
                          vertical: QPayTokens.s3,
                        ),
                      ),
                      child: Text(
                        'Resend code',
                        style: QPayType.signInChip,
                      ),
                    ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopBar(onBack: () => context.pop()),
          QHeader(
            title: 'Check your\nemail.',
            subtitle: 'We sent an 8-digit code to ${widget.email}',
          ),
          const SizedBox(height: QPayTokens.s6),
          _OtpField(
            controller: _code,
            focusNode: _focus,
            onFilled: _verify,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
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

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 24, 0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(QPayTokens.rMd),
                onTap: onBack,
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

/// Six connected boxes hovering over an invisible text field. Typing the
/// code advances through boxes; the hidden field captures every keystroke.
class _OtpField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFilled;

  const _OtpField({
    required this.controller,
    required this.focusNode,
    required this.onFilled,
  });

  @override
  State<_OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<_OtpField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_check);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_check);
    super.dispose();
  }

  static const int _codeLength = 8;

  void _check() {
    setState(() {});
    if (widget.controller.text.length == _codeLength) {
      // Defer to next frame so state update finishes.
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onFilled());
    }
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.controller.text.split('');
    return GestureDetector(
      onTap: () => widget.focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_codeLength, (i) {
                final active = i == chars.length;
                final filled = i < chars.length;
                return _OtpBox(
                  char: i < chars.length ? chars[i] : '',
                  active: active,
                  filled: filled,
                );
              }),
            ),
          ),
          // Offscreen real text field captures input and surfaces the
          // native keyboard (with SMS autofill on iOS via autofillHints).
          SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              maxLength: _codeLength,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_codeLength),
              ],
              style: const TextStyle(color: Colors.transparent),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final String char;
  final bool active;
  final bool filled;

  const _OtpBox({
    required this.char,
    required this.active,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final border = active
        ? QPayTokens.accent
        : (filled ? QPayTokens.ink : QPayTokens.border);
    return Container(
      width: 36,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: QPayTokens.cardBase.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(QPayTokens.rMd),
        border: Border.all(color: border, width: 1.5),
        boxShadow: active
            ? [
                BoxShadow(
                  color: QPayTokens.accent.withValues(alpha: 0.14),
                  spreadRadius: 4,
                )
              ]
            : null,
      ),
      child: Text(
        char,
        style: QPayType.heroTitle.copyWith(
          fontSize: 22,
          height: 1,
        ),
      ),
    );
  }
}
