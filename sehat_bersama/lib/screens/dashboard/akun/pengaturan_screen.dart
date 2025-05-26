import 'package:flutter/material.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _darkMode = false;
  bool _notifOn = true;
  bool _autoUpdate = true;

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData.light();
    final ThemeData darkTheme = ThemeData.dark().copyWith(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Colors.blue),
        trackColor: MaterialStateProperty.all(Colors.blue[200]),
      ),
    );

    return Theme(
      data: _darkMode ? darkTheme : lightTheme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Pengaturan')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Pengaturan Umum",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _darkMode,
              onChanged: (v) {
                setState(() => _darkMode = v);
              },
              title: const Text("Mode Gelap"),
              subtitle: const Text(
                "Aktifkan tampilan mode gelap untuk kenyamanan mata.",
              ),
              activeColor: Colors.blue,
            ),
            SwitchListTile(
              value: _notifOn,
              onChanged: (v) {
                setState(() => _notifOn = v);
              },
              title: const Text("Notifikasi"),
              subtitle: const Text("Terima pemberitahuan dari aplikasi."),
              activeColor: Colors.blue,
            ),
            SwitchListTile(
              value: _autoUpdate,
              onChanged: (v) {
                setState(() => _autoUpdate = v);
              },
              title: const Text("Pembaruan Otomatis"),
              subtitle: const Text(
                "Izinkan aplikasi memperbarui data secara otomatis.",
              ),
              activeColor: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              "Tentang Aplikasi",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: const Text("Versi Aplikasi"),
              subtitle: const Text("6.6.6"),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.blue),
              title: const Text("Dikembangkan oleh"),
              subtitle: const Text(
                "Kelompok 4 - Raden Galuh Garhadi C & Puti Raissa Razani",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
