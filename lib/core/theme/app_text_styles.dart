import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Roboto'; // Assuming standard sans-serif mapped to Roboto

  // Weights mapped from React Native
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Header Styles
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: black,
    color: AppColors.text,
    letterSpacing: 0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: bold,
    color: AppColors.text,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: bold,
    color: AppColors.text,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: semiBold,
    color: AppColors.text,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    color: AppColors.text,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    color: AppColors.text,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: regular,
    color: AppColors.muted,
  );

  // Captions & Micro
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.muted,
  );

  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: light,
    color: AppColors.muted,
    letterSpacing: 1.5,
  );
  
  // Specific Button Style
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: bold,
    color: AppColors.textInverse,
  );
}
