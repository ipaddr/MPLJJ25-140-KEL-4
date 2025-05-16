import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nikController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            colorFilter: const ColorFilter.mode(Color(0xFF0F5B99), BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 100,
            ),
            const SizedBox(height: 8),
            Text(
              "Selamat Datang di Sehat Bersama",
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              "Sehat Bersama, Bebas TBC Selamanya",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // NIK
            TextFormField(
              controller: nikController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: "Nomor Induk Kependudukan (NIK)",
                hintText: "16 Digit Nomor Induk Kependudukan",
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: "Alamat Email",
                hintText: "Alamat Email Pengguna Sehat Bersama",
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Password Sehat Bersama",
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Lupa kata sandi
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot-password'); 
                },
                child: const Text(
                  "Lupa Kata Sandi",
                  style: TextStyle(
                    color: Color(0xFF07477C),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Masuk
            SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  // Proses login di sini
                },
                child: const Text("Masuk"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
