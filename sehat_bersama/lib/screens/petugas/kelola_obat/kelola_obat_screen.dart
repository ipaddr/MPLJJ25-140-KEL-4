import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KelolaJadwalObatScreen extends StatefulWidget {
  const KelolaJadwalObatScreen({super.key});

  @override
  State<KelolaJadwalObatScreen> createState() =>
      _KelolaJadwalObatScreenState();
}

class _KelolaJadwalObatScreenState extends State<KelolaJadwalObatScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pasienController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  final TextEditingController _obatController = TextEditingController();
  final TextEditingController _frekuensiController = TextEditingController();

  String? _jenisObat;
  String _waktuMinum = "Sebelum Makan";

  final List<String> jenisObatList = ["Tablet", "Kapsul", "Sendok"];

  @override
  void dispose() {
    _pasienController.dispose();
    _tanggalController.dispose();
    _durasiController.dispose();
    _obatController.dispose();
    _frekuensiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011D32),
      appBar: AppBar(
        title: const Text("Kelola Jadwal Obat Pasien"),
        backgroundColor: const Color(0xFF032B45),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Nama Pasien", _pasienController),
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
                        DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
                  }
                },
                decoration: _inputDecoration("Tanggal Mulai"),
                style: const TextStyle(color: Colors.white),
                validator: (val) => val == null || val.isEmpty
                    ? "Tanggal wajib diisi"
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField("Durasi (mis. 14 Hari)", _durasiController),
              const SizedBox(height: 16),
              _buildTextField("Nama Obat (mis. Acetaminophen)", _obatController),
              const SizedBox(height: 16),
              _buildDropdownField("Jenis Takaran Obat", jenisObatList, _jenisObat,
                  (val) {
                setState(() {
                  _jenisObat = val;
                });
              }),
              const SizedBox(height: 16),
              _buildTextField("Frekuensi (berapa kali sehari)", _frekuensiController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Text("Waktu Minum", style: const TextStyle(color: Colors.white)),
              ListTile(
                title: const Text("Sebelum Makan",
                    style: TextStyle(color: Colors.white)),
                leading: Radio<String>(
                  value: "Sebelum Makan",
                  groupValue: _waktuMinum,
                  onChanged: (value) {
                    setState(() {
                      _waktuMinum = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("Sesudah Makan",
                    style: TextStyle(color: Colors.white)),
                leading: Radio<String>(
                  value: "Sesudah Makan",
                  groupValue: _waktuMinum,
                  onChanged: (value) {
                    setState(() {
                      _waktuMinum = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _jenisObat != null) {
                      final result = {
                        "pasien": _pasienController.text,
                        "mulai": _tanggalController.text,
                        "durasi": _durasiController.text,
                        "obat": _obatController.text,
                        "jenisObat": _jenisObat,
                        "frekuensi": _frekuensiController.text,
                        "waktuMinum": _waktuMinum,
                      };
                      Navigator.pop(context, result);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Upload"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF032B45),
      decoration: _inputDecoration(label),
      items: items
          .map((item) =>
              DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Colors.white))))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null || val.isEmpty ? "Wajib dipilih" : null,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
      decoration: _inputDecoration(label),
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
}
