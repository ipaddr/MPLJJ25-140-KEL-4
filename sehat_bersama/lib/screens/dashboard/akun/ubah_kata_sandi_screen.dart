import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UbahKataSandiScreen extends StatefulWidget {
  const UbahKataSandiScreen({super.key});

  @override
  State<UbahKataSandiScreen> createState() => _UbahKataSandiScreenState();
}

class _UbahKataSandiScreenState extends State<UbahKataSandiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  Future<void> _ubahKataSandi() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: _oldPasswordController.text,
      );
      // Re-authenticate
      await user.reauthenticateWithCredential(cred);
      // Update password
      await user.updatePassword(_newPasswordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kata sandi berhasil diubah!')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Gagal mengubah kata sandi.';
      if (e.code == 'wrong-password') {
        msg = 'Kata sandi lama salah.';
      } else if (e.code == 'weak-password') {
        msg = 'Kata sandi baru terlalu lemah.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan.')));
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Kata Sandi')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_showOldPassword,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Lama',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showOldPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showOldPassword = !_showOldPassword;
                      });
                    },
                  ),
                ),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'Masukkan kata sandi lama'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Baru',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Masukkan kata sandi baru';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi Baru',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                ),
                validator:
                    (v) =>
                        v != _newPasswordController.text
                            ? 'Konfirmasi tidak cocok'
                            : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _ubahKataSandi,
                child:
                    _loading
                        ? const CircularProgressIndicator()
                        : const Text('Ubah Kata Sandi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
