import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verification_method_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/verification_method_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/login_petugas_screen.dart';

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
      routes: {
        '/register': (_) => const RegisterScreen(),
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/verification-method': (_) => const VerificationMethodScreen(),
        '/email-verification': (_) => const EmailVerificationScreen(),
        '/otp-verification': (_) => const OtpVerificationScreen(),
        '/login-petugas': (_) => const LoginPetugasScreen(),

      },
    );
  }
}