import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const SehatBersamaApp(),
    ),
  );
}

class SehatBersamaApp extends StatelessWidget {
  const SehatBersamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehat Bersama',
      debugShowCheckedModeBanner: false,
      theme: sehatBersamaTheme,
      home: const SplashScreen(),
    );
  }
}
