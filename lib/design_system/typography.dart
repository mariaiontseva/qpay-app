import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// QPay typography presets — mirrors qpay-tokens.jsx styles used across
/// screens S01 – S05 of the formation flow.
class QPayType {
  QPayType._();

  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    required double lineHeight,
    double tracking = 0,
    Color color = QPayTokens.ink,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        height: lineHeight,
        letterSpacing: tracking,
        color: color,
      );

  static TextStyle _mono({
    required double size,
    required FontWeight weight,
    required double lineHeight,
    double tracking = 0,
    Color color = QPayTokens.ink3,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        height: lineHeight,
        letterSpacing: tracking,
        color: color,
      );

  // ───── Display / headings ─────
  // Hero title — 800 34/1.08, consistent across every step.
  static TextStyle get heroTitle => _sans(
        size: 34,
        weight: FontWeight.w800,
        lineHeight: 1.08,
        tracking: -1.02,
      );

  static TextStyle get heroSub => _sans(
        size: 15,
        weight: FontWeight.w400,
        lineHeight: 1.45,
        color: QPayTokens.ink2,
      );

  // Wordmark — 800 18/1 letter-spacing -0.02em
  static TextStyle get wordmark => _sans(
        size: 18,
        weight: FontWeight.w800,
        lineHeight: 1,
        tracking: -0.36,
      );

  // ───── Option cards ─────
  static TextStyle get optionTitle => _sans(
        size: 16,
        weight: FontWeight.w700,
        lineHeight: 1.2,
        tracking: -0.24,
      );

  static TextStyle get optionSub => _sans(
        size: 12.5,
        weight: FontWeight.w400,
        lineHeight: 1.45,
        color: QPayTokens.ink2,
      );

  // ───── Fields ─────
  // Label intentionally reuses the subtitle style — same weight + color.
  static TextStyle get fieldLabel => _sans(
        size: 15,
        weight: FontWeight.w400,
        lineHeight: 1.45,
        color: QPayTokens.ink2,
      );

  static TextStyle get fieldInput => _sans(
        size: 17,
        weight: FontWeight.w500,
        lineHeight: 1.4,
      );

  static TextStyle get fieldPrefix => _sans(
        size: 17,
        weight: FontWeight.w500,
        lineHeight: 1,
        color: QPayTokens.ink2,
      );

  static TextStyle get fieldHint => _sans(
        size: 13,
        weight: FontWeight.w400,
        lineHeight: 1.4,
        color: QPayTokens.ink3,
      );

  // ───── Button ─────
  static TextStyle get buttonLg => _sans(
        size: 15,
        weight: FontWeight.w700,
        lineHeight: 1,
        tracking: -0.075,
        color: QPayTokens.primaryInk,
      );

  static TextStyle get buttonSecondary => _sans(
        size: 15,
        weight: FontWeight.w700,
        lineHeight: 1,
        tracking: -0.075,
        color: QPayTokens.ink,
      );

  static TextStyle get signInChip => _sans(
        size: 15,
        weight: FontWeight.w600,
        lineHeight: 1,
      );

  // ───── Checklist ─────
  static TextStyle get checklistTitle => _sans(
        size: 14,
        weight: FontWeight.w700,
        lineHeight: 1.3,
        tracking: -0.07,
      );

  static TextStyle get checklistSub => _sans(
        size: 12.5,
        weight: FontWeight.w400,
        lineHeight: 1.45,
        color: QPayTokens.ink2,
      );

  static TextStyle get checklistNumber => _mono(
        size: 12,
        weight: FontWeight.w700,
        lineHeight: 1,
        tracking: 0.24,
        color: const Color(0xFFFFFCF5),
      );

  // ───── Name-availability status ─────
  static TextStyle get statusLine => _sans(
        size: 12.5,
        weight: FontWeight.w500,
        lineHeight: 1.3,
        color: QPayTokens.ink2,
      );

  static TextStyle get statusLineStrong => _sans(
        size: 12.5,
        weight: FontWeight.w700,
        lineHeight: 1.3,
      );

  // ───── Misc ─────
  static TextStyle get termsFooter => _sans(
        size: 11,
        weight: FontWeight.w400,
        lineHeight: 1.5,
        color: QPayTokens.ink3,
      );

  static TextStyle get termsFooterStrong => _sans(
        size: 11,
        weight: FontWeight.w600,
        lineHeight: 1.5,
        color: QPayTokens.ink,
      );

  static TextStyle get progressNum => _mono(
        size: 11,
        weight: FontWeight.w600,
        lineHeight: 1,
        tracking: 0.44,
      );

  static TextStyle get footerNote => _sans(
        size: 11.5,
        weight: FontWeight.w400,
        lineHeight: 1.5,
        color: QPayTokens.ink3,
      );
}
