import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

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

  // Replace with your actual API base URL
  static const String baseUrl = 'https://your-api-url.com/api';

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
      body: SingleChildScrollView(
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
                _buildTextField("Nomor Induk Kependudukan (NIK)", nikController),
                const SizedBox(height: 12),
                _buildTextField("Nama Lengkap", nameController),
                const SizedBox(height: 12),
                _buildTextField("Tanggal Lahir", birthController, isDate: true),
                const SizedBox(height: 24),
                _buildPrimaryButton("Verifikasi Data", _verifyData),
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
                _buildTextField("Nomor Telepon", phoneController),
                const SizedBox(height: 12),
                _buildTextField("Alamat Email", emailController),
                const SizedBox(height: 12),
                _buildTextField(
                  "Password",
                  passwordController,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  toggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
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
                ),
                const SizedBox(height: 24),
                _buildPrimaryButton("Registrasi", _registerUser),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyData() async {
    if (nikController.text.isEmpty ||
        nameController.text.isEmpty ||
        birthController.text.isEmpty) {
      _showSnackBar("Silakan lengkapi semua data.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify'), // Replace with your verify endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nik': nikController.text,
          'name': nameController.text,
          'birthDate': birthController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Check if verification was successful
        if (responseData['message'] == 'Verifikasi berhasil') {
          setState(() {
            isStep2 = true;
          });
          _showSnackBar("Verifikasi berhasil! Silakan lengkapi data registrasi.");
        } else {
          _showSnackBar("Verifikasi gagal. Silakan periksa data Anda.");
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(errorData['message'] ?? "Verifikasi gagal. Silakan coba lagi.");
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan. Periksa koneksi internet Anda.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'), // Replace with your register endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nik': nikController.text,
          'name': nameController.text,
          'birthDate': birthController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Check if registration was successful
        if (responseData['message'] == 'Registrasi berhasil') {
          // Store the token if needed (you might want to use SharedPreferences)
          final token = responseData['token'];
          final userId = responseData['userId'];
          
          _showSnackBar("Pendaftaran berhasil!");
          
          // Navigate to login screen or home screen
          // Navigator.pushReplacementNamed(context, '/login');
          // or
          // Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showSnackBar("Registrasi gagal. Silakan coba lagi.");
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(errorData['message'] ?? "Registrasi gagal. Silakan coba lagi.");
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan. Periksa koneksi internet Anda.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isDate = false,
    bool obscureText = true,
    VoidCallback? toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      readOnly: isDate,
      style: const TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) return "$label tidak boleh kosong";
        
        // NIK validation
        if (label == "Nomor Induk Kependudukan (NIK)") {
          if (value.length != 16) return "NIK harus 16 digit";
          if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "NIK hanya boleh berisi angka";
        }
        
        // Email validation
        if (label == "Alamat Email") {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return "Format email tidak valid";
          }
        }
        
        // Phone validation
        if (label == "Nomor Telepon") {
          if (!RegExp(r'^[0-9+]+$').hasMatch(value)) return "Nomor telepon tidak valid";
        }
        
        // Password validation
        if (label == "Password") {
          if (value.length < 6) return "Password minimal 6 karakter";
        }
        
        if (label == "Konfirmasi Password" && value != passwordController.text) {
          return "Konfirmasi password tidak cocok";
        }
        
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
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}