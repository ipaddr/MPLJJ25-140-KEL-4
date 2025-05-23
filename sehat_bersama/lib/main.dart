import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
 // Import flutter_dotenv


// Import semua screen Anda (pastikan path-nya benar)
import 'theme/theme.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verification_method_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/login_petugas_screen.dart';
import 'screens/petugas/dashboard_petugas.dart';
import 'screens/dashboard/dashboard.dart';
import 'screens/dashboard/registrasi/registrasi_screen.dart';
import 'screens/dashboard/registrasi/registrasi_berhasil_screen.dart';
import 'screens/dashboard/antrean/layanan_antrean_screen.dart';
import 'screens/dashboard/antrean/cetak_antrean_screen.dart';
import 'screens/dashboard/antrean/checkin_antrean_berhasil_screen.dart';
import 'screens/dashboard/penjadwalan/penjadwalan_screen.dart';
import 'screens/dashboard/penjadwalan/jadwal_sukses_screen.dart';
import 'screens/dashboard/hasil_pemeriksaan/hasil_pemeriksaan.dart';
import 'screens/dashboard/screening/screening_tbc_screen.dart';
import 'screens/dashboard/akun/profile_screen.dart';
import 'screens/chatbot/chabot_screen.dart'; 
import 'screens/berita/berita_list_screen.dart'; // Import berita list screen
import 'screens/berita/berita_detail_screen.dart'; // Import berita detail screen
import 'screens/petugas/kelola_jadwal/kelola_jadwal_screen.dart' as kelola_jadwal; // Import kelola jadwal pemeriksaan
import 'screens/petugas/kelola_jadwal/jadwal_list_screen.dart'; // Import jadwal list screen
import 'screens/petugas/hasil_pemeriksaan/input_hasil_screen.dart'; // Import input hasil pemeriksaan

// Fungsi main() diubah menjadi async untuk await dotenv.load()
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null); // Atau 'en_US' jika pakai format Inggris

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
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
        '/dashboard-petugas': (_) => const DashboardPetugasScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/registrasi-online': (_) => const RegistrasiOnlineScreen(),
        '/registrasi-berhasil': (_) => const RegistrasiBerhasilScreen(),
        '/layanan-antrean': (_) => const LayananAntreanScreen(),
        '/cetak-antrean': (_) => const CetakAntreanScreen(),
        '/checkin-berhasil': (_) => const checkin_antrean_berhasil_screen(),
        '/penjadwalan': (_) => const PenjadwalanScreen(),
        '/jadwal-sukses': (_) => const JadwalSuksesScreen(),
        '/hasil': (_) => const HasilPemeriksaanScreen(),
        '/screening': (_) => const ScreeningTBCScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/chatbot': (_) => const ChatbotScreen(),
        '/kelola-jadwal': (_) => const kelola_jadwal.KelolaJadwalScreen(),
        '/input-hasil': (_) => const InputHasilPemeriksaanScreen(),
        '/berita': (_) => const BeritaListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/list-jadwal') {
          return MaterialPageRoute(
            builder: (context) => const JadwalListScreen(),
          );
        }
        if (settings.name == '/berita-detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => BeritaDetailScreen(article: args['article']),
          );
        }
        // Default fallback
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      },
    );
  }
}
