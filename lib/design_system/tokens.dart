import 'package:flutter/material.dart';

/// QPay design tokens. Source of truth: qpay-tokens.jsx from the Claude Design
/// handoff bundle. Warm-cream canvas, black CTAs, sunset accent.
class QPayTokens {
  QPayTokens._();

  // ───── Canvas & surface ─────
  static const Color canvas = Color(0xFFF5EDE2);
  static const Color canvasSoft = Color(0xFFFBF4EA);
  static const Color surface = Color(0xFFF5EDE2);
  static const Color surface2 = Color(0xFFEDE3D4);
  static const Color cardBase = Color(0xFFFFFCF5);

  // ───── Ink ─────
  static const Color ink = Color(0xFF1A1410);
  static const Color ink2 = Color(0xFF5C4F42);
  static const Color ink3 = Color(0xFF8F7F6E);
  static const Color ink4 = Color(0xFFB8A895);

  // ───── Accents ─────
  static const Color accent = Color(0xFFF06A3D);
  static const Color accentSoft = Color(0xFFFCE3D3);
  static const Color accentPink = Color(0xFFEE5A8B);
  static const Color accentYellow = Color(0xFFF5C76A);

  // ───── Brand ─────
  static const Color primary = Color(0xFF1A1410);
  static const Color primaryInk = Color(0xFFFFFFFF);

  // ───── Borders ─────
  static const Color border = Color(0xFFE2D6C4);
  static const Color borderStrong = Color(0xFFC8B8A2);

  // ───── Neutrals ─────
  static const Color n100 = Color(0xFFEDE3D4);
  static const Color n200 = Color(0xFFE2D6C4);
  static const Color n300 = Color(0xFFC8B8A2);

  // ───── Semantic ─────
  static const Color success = Color(0xFF3E7D5A);
  static const Color successBg = Color(0xFFE3EEE6);
  static const Color alert = Color(0xFFC64A2E);
  static const Color alertBg = Color(0xFFFBE4D8);
  static const Color warn = Color(0xFFB07D1E);
  static const Color warnBg = Color(0xFFFBEFD4);

  // ───── Spacing (4-pt grid) ─────
  static const double s1 = 2;
  static const double s2 = 4;
  static const double s3 = 8;
  static const double s4 = 12;
  static const double s5 = 16;
  static const double s6 = 24;
  static const double s7 = 32;
  static const double s8 = 48;

  // ───── Radii ─────
  static const double rXs = 4;
  static const double rSm = 8;
  static const double rMd = 12;
  static const double rCard = 18;
  static const double rLg = 20;
  static const double rPill = 999;

  // ───── Motion ─────
  static const Duration durFast = Duration(milliseconds: 120);
  static const Duration dur = Duration(milliseconds: 200);
  static const Duration durSlow = Duration(milliseconds: 320);
  static const Curve ease = Curves.easeOutCubic;
}
