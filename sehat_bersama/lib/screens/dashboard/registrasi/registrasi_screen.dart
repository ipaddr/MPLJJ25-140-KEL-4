import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrasiOnlineScreen extends StatefulWidget {
  const RegistrasiOnlineScreen({super.key});

  @override
  State<RegistrasiOnlineScreen> createState() => _RegistrasiOnlineScreenState();
}

class _RegistrasiOnlineScreenState extends State<RegistrasiOnlineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  String? selectedGender;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('registrasi_online').add({
        'nama': namaController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'tanggal': tanggalController.text.trim(),
        'gender': selectedGender,
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() => _loading = false);
      Navigator.pushNamed(context, '/registrasi-berhasil');
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrasi Online"),
        titleTextStyle: const TextStyle(
          color: Color(0xFF07477C),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF07477C)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInput(
                "Nama Lengkap",
                namaController,
                validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              _buildInput(
                "Alamat Email",
                emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Email wajib diisi";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                    return "Format email tidak valid";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildInput(
                "Nomor Telepon",
                phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return "Nomor telepon wajib diisi";
                  if (!RegExp(r'^\d{10,15}$').hasMatch(val)) {
                    return "Nomor telepon tidak valid";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: tanggalController,
                readOnly: true,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Tanggal Pemeriksaan",
                  labelStyle: const TextStyle(color: Colors.black),
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Tanggal wajib diisi"
                            : null,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    tanggalController.text =
                        "${picked.day}/${picked.month}/${picked.year}";
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: InputDecoration(
                  labelText: "Jenis Kelamin",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Laki-laki",
                    child: Text("Laki-laki"),
                  ),
                  DropdownMenuItem(
                    value: "Perempuan",
                    child: Text("Perempuan"),
                  ),
                ],
                validator:
                    (val) => val == null ? "Jenis kelamin wajib dipilih" : null,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07477C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _loading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text("Daftar Sekarang"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
