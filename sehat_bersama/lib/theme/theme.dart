import 'package:flutter/material.dart';

final ThemeData sehatBersamaTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF07477C), // biru tua
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Roboto',

  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF07477C), // biru tua
    secondary: const Color(0xFF66BB6A), // hijau checklist (opsional)
    surface: const Color(0xFFC8E1F6),   // biru muda
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF07477C),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    titleMedium: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    labelLarge: TextStyle(color: Colors.white),
  ),

  iconTheme: const IconThemeData(
    color: Color(0xFF07477C),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF07477C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  cardColor: const Color(0xFFC8E1F6), // Kartu/info background
  inputDecorationTheme: InputDecorationTheme(
    fillColor: const Color(0xFFC8E1F6),
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
  ),
);
