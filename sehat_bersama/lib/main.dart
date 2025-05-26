import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'screens/dashboard/hasil_pemeriksaan/hasil_pemeriksaan.dart';
import 'screens/dashboard/screening/screening_tbc_screen.dart';
import 'screens/dashboard/akun/profile_screen.dart';
import 'screens/chatbot/chabot_screen.dart';
import 'screens/berita/berita_list_screen.dart';
import 'screens/berita/berita_detail_screen.dart';
import 'screens/petugas/kelola_jadwal/kelola_jadwal_screen.dart'
    as kelola_jadwal;
import 'screens/petugas/kelola_jadwal/jadwal_list_screen.dart';
import 'screens/petugas/hasil_pemeriksaan/input_hasil_screen.dart';
import 'screens/petugas/kelola_obat/kelola_obat_screen.dart';
import 'screens/dashboard/akun/keamanan_privasi_screen.dart';
import 'screens/dashboard/akun/panduan_aplikasi_screen.dart';
import 'screens/dashboard/akun/pengaturan_screen.dart';
import 'screens/dashboard/akun/ubah_kata_sandi_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      routes: {
        '/register': (_) => const RegisterScreen(),
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/verification-method': (_) => const VerificationMethodScreen(),
        '/email-verification': (_) => const EmailVerificationScreen(),
        '/otp-verification': (_) => const OtpVerificationScreen(),
        '/login-petugas': (_) => const LoginPetugasScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/registrasi-online': (_) => const RegistrasiOnlineScreen(),
        '/registrasi-berhasil': (_) => const RegistrasiBerhasilScreen(),
        '/layanan-antrean': (_) => const LayananAntreanScreen(),
        '/cetak-antrean': (_) => const CetakAntreanScreen(),
        '/checkin-berhasil': (_) => const CheckinAntreanBerhasilScreen(),
        '/penjadwalan': (_) => const PenjadwalanScreen(),
        '/dashboard-petugas': (_) => const DashboardPetugasScreen(),
        '/hasil-pemeriksaan': (_) => const HasilPemeriksaanScreen(),
        '/screening': (_) => const ScreeningTBCScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/chatbot': (_) => const ChatbotScreen(),
        '/kelola-jadwal': (_) => const kelola_jadwal.KelolaJadwalScreen(),
        '/input-hasil': (_) => const InputHasilPemeriksaanScreen(),
        '/berita': (_) => const BeritaListScreen(),
        '/kelola-obat': (_) => const KelolaJadwalObatScreen(),
        '/ubah-kata-sandi': (_) => const UbahKataSandiScreen(),
        '/keamanan-privasi': (_) => const KeamananPrivasiScreen(),
        '/panduan-aplikasi': (_) => const PanduanAplikasiScreen(),
        '/pengaturan': (_) => const PengaturanScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle route dengan arguments
        switch (settings.name) {
          case '/hasil-pemeriksaan':
            return MaterialPageRoute(
              builder: (context) => const HasilPemeriksaanScreen(),
              settings: settings, // Penting! Pass settings untuk arguments
            );

          case '/list-jadwal':
            return MaterialPageRoute(
              builder: (context) => const JadwalListScreen(),
              settings: settings,
            );

          case '/berita-detail':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null && args.containsKey('article')) {
              return MaterialPageRoute(
                builder: (_) => BeritaDetailScreen(article: args['article']),
                settings: settings,
              );
            }
            // Fallback jika arguments tidak valid
            return MaterialPageRoute(
              builder: (context) => const BeritaListScreen(),
            );

          default:
            // Default fallback untuk route yang tidak dikenal
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
        }
      },
    );
  }
}
