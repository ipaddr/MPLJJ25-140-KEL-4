import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController nikController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isStep2 = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    nikController.dispose();
    nameController.dispose();
    birthController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk memverifikasi NIK (contoh sederhana)
  Future<bool> _verifyNIK() async {
    setState(() => _isLoading = true);
    
    try {
      // Cek apakah NIK sudah terdaftar
      final nikQuery = await _firestore
          .collection('users')
          .where('nik', isEqualTo: nikController.text)
          .get();
      
      if (nikQuery.docs.isNotEmpty) {
        _showErrorMessage("NIK sudah terdaftar dalam sistem");
        return false;
      }
      
      // Simulasi verifikasi NIK dengan delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Di sini Anda bisa menambahkan logika verifikasi NIK yang sesungguhnya
      // dengan API eksternal atau database validasi
      
      return true;
    } catch (e) {
      _showErrorMessage("Terjadi kesalahan saat verifikasi: $e");
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk registrasi user
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Cek apakah email sudah terdaftar
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: emailController.text.toLowerCase())
          .get();
      
      if (emailQuery.docs.isNotEmpty) {
        _showErrorMessage("Email sudah terdaftar");
        return;
      }

      // Buat akun Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.toLowerCase(),
        password: passwordController.text,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Simpan data user ke Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'nik': nikController.text,
          'name': nameController.text,
          'birthDate': birthController.text,
          'phone': phoneController.text,
          'email': emailController.text.toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        // Update display name di Firebase Auth
        await user.updateDisplayName(nameController.text);

        _showSuccessMessage("Pendaftaran berhasil! Silakan login.");
        
        // Kembali ke halaman sebelumnya setelah 2 detik
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Terjadi kesalahan saat registrasi";
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = "Password terlalu lemah";
          break;
        case 'email-already-in-use':
          errorMessage = "Email sudah digunakan";
          break;
        case 'invalid-email':
          errorMessage = "Format email tidak valid";
          break;
        default:
          errorMessage = "Terjadi kesalahan: ${e.message}";
      }
      
      _showErrorMessage(errorMessage);
    } catch (e) {
      _showErrorMessage("Terjadi kesalahan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            colorFilter: const ColorFilter.mode(Color(0xFF0F5B99), BlendMode.srcIn),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pendaftaran Pengguna Aplikasi',
          style: textTheme.titleMedium?.copyWith(color: const Color(0xFF0F5B99)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
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
                    "Silahkan isi data diri Anda dengan sesuai.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  if (!isStep2) ...[
                    _buildTextField("Nomor Induk Kependudukan (NIK)", nikController, 
                      validator: (value) {
                        if (value == null || value.isEmpty) return "NIK tidak boleh kosong";
                        if (value.length != 16) return "NIK harus 16 digit";
                        if (!RegExp(r'^\d+$').hasMatch(value)) return "NIK hanya boleh berisi angka";
                        return null;
                      }
                    ),
                    const SizedBox(height: 12),
                    _buildTextField("Nama Lengkap", nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Nama tidak boleh kosong";
                        if (value.length < 2) return "Nama minimal 2 karakter";
                        return null;
                      }
                    ),
                    const SizedBox(height: 12),
                    _buildTextField("Tanggal Lahir", birthController, isDate: true),
                    const SizedBox(height: 24),
                    _buildPrimaryButton("Verifikasi Data", () async {
                      if (_formKey.currentState!.validate()) {
                        final isValid = await _verifyNIK();
                        if (isValid) {
                          setState(() {
                            isStep2 = true;
                          });
                        }
                      }
                    }),
                  ] else ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Nomor Induk Kependudukan (NIK)\n${nikController.text}",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F5B99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField("Nomor Telepon", phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Nomor telepon tidak boleh kosong";
                        if (!RegExp(r'^(\+62|62|0)[0-9]{8,13}$').hasMatch(value)) {
                          return "Format nomor telepon tidak valid";
                        }
                        return null;
                      }
                    ),
                    const SizedBox(height: 12),
                    _buildTextField("Alamat Email", emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Email tidak boleh kosong";
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return "Format email tidak valid";
                        }
                        return null;
                      }
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      "Password",
                      passwordController,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      toggleVisibility: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Password tidak boleh kosong";
                        if (value.length < 8) return "Password minimal 8 karakter";
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                          return "Password harus mengandung huruf besar, kecil, dan angka";
                        }
                        return null;
                      }
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      "Konfirmasi Password",
                      confirmPasswordController,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      toggleVisibility: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Konfirmasi password tidak boleh kosong";
                        if (value != passwordController.text) return "Konfirmasi password tidak cocok";
                        return null;
                      }
                    ),
                    const SizedBox(height: 24),
                    _buildPrimaryButton("Registrasi", _registerUser),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isStep2 = false;
                        });
                      },
                      child: const Text("Kembali ke Step 1"),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isDate = false,
    bool obscureText = true,
    VoidCallback? toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      readOnly: isDate,
      keyboardType: label.contains("NIK") || label.contains("Telepon") 
          ? TextInputType.number 
          : label.contains("Email") 
              ? TextInputType.emailAddress 
              : TextInputType.text,
      style: const TextStyle(color: Colors.black),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return "$label tidak boleh kosong";
        return null;
      },
      onTap: isDate
          ? () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                birthController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
              }
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              )
            : isDate
                ? const Icon(Icons.calendar_today)
                : null,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0F5B99)),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F5B99),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}