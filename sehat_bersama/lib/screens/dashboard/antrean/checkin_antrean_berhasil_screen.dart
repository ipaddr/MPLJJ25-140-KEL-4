import 'package:flutter/material.dart';

class checkin_antrean_berhasil_screen extends StatelessWidget {
  const checkin_antrean_berhasil_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F5B99)),
          onPressed: () => Navigator.pop(context, '/dashboard'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
  child: Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisSize: MainAxisSize.min, // supaya tidak memenuhi seluruh tinggi layar
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 100,
        ),
        const SizedBox(height: 32),
        const Text(
          "Check-In Antrean Berhasil",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 24),
        const Text(
          "Silahkan Menunggu Antrean Anda Dipanggil",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      ],
    ),
  ),
),

    );
  }
}
