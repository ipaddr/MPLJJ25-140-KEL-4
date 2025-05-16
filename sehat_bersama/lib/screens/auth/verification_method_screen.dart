import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VerificationMethodScreen extends StatelessWidget {
  const VerificationMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            colorFilter: const ColorFilter.mode(Color(0xFF0F5B99), BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Pilih Metode Verifikasi", style: TextStyle(color: Color(0xFF0F5B99))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Image.asset('assets/images/logo.png', height: 100),
            const SizedBox(height: 24),
            const Text(
              "Pilih salah satu metode verifikasi dibawah ini",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF0F5B99)),
                title: const Text("Email"),
                onTap: () {
                  Navigator.pushNamed(context, '/email-verification');
                },
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Email Saya sudah tidak aktif",
                style: TextStyle(color: Color(0xFF0F5B99)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
