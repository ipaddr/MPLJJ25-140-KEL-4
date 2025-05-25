import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                _buildPrimaryButton("Verifikasi Data", () {
                  if (nikController.text.isNotEmpty &&
                      nameController.text.isNotEmpty &&
                      birthController.text.isNotEmpty) {
                    setState(() {
                      isStep2 = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Silakan lengkapi semua data.")),
                    );
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
                _buildPrimaryButton("Registrasi", () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pendaftaran berhasil!")),
                    );
                  }
                }),
              ],
            ],
          ),
        ),
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      readOnly: isDate,
      style: const TextStyle(color: Colors.black), // Teks input berwarna hitam
      validator: (value) {
        if (value == null || value.isEmpty) return "$label tidak boleh kosong";
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
                birthController.text = "${picked.day}/${picked.month}/${picked.year}";
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
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}