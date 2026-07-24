import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // Extracted elevation logic from RN source (elevation: 6 mapped to shadow)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000), // ~10% opacity black
      offset: Offset(0, 4),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0D000000), // ~5% opacity black
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
}
