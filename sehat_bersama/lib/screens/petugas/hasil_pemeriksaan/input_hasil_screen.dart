import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _catatanController = TextEditingController();

  String? _selectedPasien;
  DateTime? _selectedDate;
  List<String> _listPasien = [];
  bool _loadingPasien = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _fetchPasien();
  }

  Future<void> _fetchPasien() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('registrasi_online')
              .get();
      setState(() {
        _listPasien =
            snapshot.docs
                .map((doc) => doc.data()['nama']?.toString() ?? '')
                .where((nama) => nama.isNotEmpty)
                .toList();
        _loadingPasien = false;
      });
    } catch (e) {
      setState(() => _loadingPasien = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data pasien: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011D32),
      appBar: AppBar(
        title: const Text("Input Hasil Pemeriksaan"),
        backgroundColor: const Color(0xFF032B45),
      ),
      body:
          _loadingPasien
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedPasien,
                        decoration: _inputDecoration("Nama Pasien"),
                        items:
                            _listPasien
                                .map(
                                  (nama) => DropdownMenuItem(
                                    value: nama,
                                    child: Text(
                                      nama,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        dropdownColor: const Color(0xFF032B45),
                        onChanged:
                            (val) => setState(() => _selectedPasien = val),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Wajib dipilih"
                                    : null,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tanggalController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.white),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                              _tanggalController.text = DateFormat(
                                'dd-MM-yyyy',
                              ).format(picked);
                            });
                          }
                        },
                        decoration: _inputDecoration("Tanggal Pemeriksaan"),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Wajib diisi"
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Catatan Pemeriksaan",
                        _catatanController,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _uploading
                                  ? null
                                  : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => _uploading = true);
                                      final hasil = {
                                        'namaPasien': _selectedPasien,
                                        'tanggal':
                                            _selectedDate != null
                                                ? Timestamp.fromDate(
                                                  _selectedDate!,
                                                )
                                                : null,
                                        'catatan': _catatanController.text,
                                      };
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('hasil_pemeriksaan')
                                            .add(hasil);
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Hasil pemeriksaan berhasil disimpan!",
                                              ),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Gagal simpan data: $e",
                                            ),
                                          ),
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() => _uploading = false);
                                        }
                                      }
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child:
                              _uploading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text("Simpan Hasil Pemeriksaan"),
                        ),
                      ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
