import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Hero — 48px DM Serif Display
  static TextStyle get hero => GoogleFonts.dmSerifDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.1,
      );

  // H1 — 32px DM Serif Display
  static TextStyle get h1 => GoogleFonts.dmSerifDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // H1 italic
  static TextStyle get h1Italic => GoogleFonts.dmSerifDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // H2 — 22px DM Sans 600
  static TextStyle get h2 => GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // H3 — 16px DM Sans 500
  static TextStyle get h3 => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // Body — 15px DM Sans 400
  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // Body secondary
  static TextStyle get bodySecondary => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Caption — 12px DM Sans 400 #888
  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // Micro — 11px DM Sans caps
  static TextStyle get micro => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.08 * 11,
      );

  // Micro caps
  static TextStyle get microCaps => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.08 * 11,
      ).copyWith(
        decoration: TextDecoration.none,
      );

  // Number large (for ₹ amounts)
  static TextStyle get numberLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        color: AppColors.accentLime,
        height: 1.0,
      );

  static TextStyle get numberMedium => GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // Quote style
  static TextStyle get quote => GoogleFonts.dmSerifDisplay(
        fontSize: 22,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
        height: 1.45,
      );

  static TextStyle get quoteSmall => GoogleFonts.dmSerifDisplay(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
        height: 1.45,
      );

  // Label
  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // Button text
  static TextStyle get button => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.background,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonOutline => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      );
}
