import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class InputHasilPemeriksaanScreen extends StatefulWidget {
  const InputHasilPemeriksaanScreen({super.key});

  @override
  State<InputHasilPemeriksaanScreen> createState() =>
      _InputHasilPemeriksaanScreenState();
}

class _InputHasilPemeriksaanScreenState
    extends State<InputHasilPemeriksaanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _namaPasienController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  File? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011D32),
      appBar: AppBar(
        title: const Text("Input Hasil Pemeriksaan"),
        backgroundColor: const Color(0xFF032B45),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Nama Pasien", _namaPasienController),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _tanggalController.text =
                        DateFormat('dd-MM-yyyy').format(picked);
                  }
                },
                decoration: _inputDecoration("Tanggal Pemeriksaan"),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _selectedFile != null
                      ? "File dipilih: ${_selectedFile!.path.split('/').last}"
                      : "Unggah File",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF032B45),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField("Catatan Pemeriksaan", _catatanController,
                  maxLines: 4),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedFile != null) {
                      final hasil = {
                        'namaPasien': _namaPasienController.text,
                        'tanggal': _tanggalController.text,
                        'file': _selectedFile,
                        'catatan': _catatanController.text,
                      };
                      Navigator.pop(context, hasil);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Simpan Hasil Pemeriksaan"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: const Color(0xFF032B45),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
      decoration: _inputDecoration(label),
    );
  }
}
