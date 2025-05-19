import 'package:flutter/material.dart';

class JadwalSuksesScreen extends StatelessWidget {
  const JadwalSuksesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 80),
              const SizedBox(height: 24),
              const Text(
                "Penjadwalan Pemeriksaan Berhasil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                "Silahkan Menuju ke Rumah Sakit\nSesuai Jadwal Tertera",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                child: const Text("Kembali ke Menu Utama"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
