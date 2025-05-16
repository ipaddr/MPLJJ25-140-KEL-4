import 'package:flutter/material.dart';

final ThemeData sehatBersamaTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF07477C), // Biru tua
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Roboto',

  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF07477C),
    secondary: const Color(0xFF66BB6A),
    surface: const Color(0xFFC8E1F6),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFF0F5B99),
    elevation: 0,
    centerTitle: true,
  ),

  iconTheme: const IconThemeData(
    color: Color(0xFF07477C),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF07477C),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 17, color: Colors.white), // untuk tagline splash
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black87), // untuk subjudul
    labelLarge: TextStyle(color: Colors.white),
  ),

  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.white,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF07477C)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF07477C), width: 2),
    ),
    labelStyle: const TextStyle(color: Color(0xFF07477C)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  cardColor: const Color(0xFFC8E1F6),
);
