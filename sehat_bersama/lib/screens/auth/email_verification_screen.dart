import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            colorFilter: const ColorFilter.mode(Color(0xFF0F5B99), BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Verifikasi Email", style: TextStyle(color: Color(0xFF0F5B99))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Silakan masukkan alamat Email kamu. Pastikan alamat Email yang dimasukkan benar, karena sistem akan mengirimkan kode verifikasi ke Email tersebut",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: emailController,
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "contoh : alamat@email.com",
                labelText: "Email",
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/otp-verification');
              },
              child: const Text("Kirim Kode Verifikasi"),
            ),
          ],
        ),
      ),
    );
  }
}
