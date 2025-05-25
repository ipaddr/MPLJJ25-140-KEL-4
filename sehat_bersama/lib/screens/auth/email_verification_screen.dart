import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _sendVerification() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // Generate kode OTP 6 digit
    String otp = (Random().nextInt(900000) + 100000).toString();

    // Simpan kode OTP ke Firestore
    await FirebaseFirestore.instance
        .collection('email_verifications')
        .doc(emailController.text.trim())
        .set({
      'otp': otp,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _loading = false);

    // Tampilkan OTP ke user (hanya untuk demo/testing)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kode OTP (Demo)'),
        content: Text('Kode OTP Anda: $otp\n\n(Catatan: Ini hanya untuk demo, tidak terkirim ke email)'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/otp-verification', arguments: {
                'email': emailController.text.trim(),
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
        title: const Text("Verifikasi Email", style: TextStyle(color: Color(0xFF0F5B99))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _sendVerification,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Kirim Kode Verifikasi"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
