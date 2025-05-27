import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KelolaJadwalObatScreen extends StatefulWidget {
  const KelolaJadwalObatScreen({super.key});

  @override
  State<KelolaJadwalObatScreen> createState() => _KelolaJadwalObatScreenState();
}

class _KelolaJadwalObatScreenState extends State<KelolaJadwalObatScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  final TextEditingController _obatController = TextEditingController();
  final TextEditingController _frekuensiController = TextEditingController();

  String? _selectedPasien;
  List<String> _listPasien = [];
  bool _loadingPasien = true;

  String? _jenisObat;
  String _waktuMinum = "Sebelum Makan";

  final List<String> jenisObatList = ["Tablet", "Kapsul", "Sendok"];

  @override
  void initState() {
    super.initState();
    _fetchPasien();
  }

  Future<void> _fetchPasien() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('registrasi_online').get();
    setState(() {
      _listPasien =
          snapshot.docs
              .map((doc) => doc.data()['nama']?.toString() ?? '')
              .where((nama) => nama.isNotEmpty)
              .toList();
      _loadingPasien = false;
    });
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _durasiController.dispose();
    _obatController.dispose();
    _frekuensiController.dispose();
    super.dispose();
  }

  Future<void> _simpanKeFirestore(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('jadwal_obat').add(data);
  }

  Future<void> _showSuccessDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SuccessDialogObat(),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
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
              _loadingPasien
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                    value: _selectedPasien,
                    decoration: _inputDecoration("Nama Pasien"),
                    items:
                        _listPasien
                            .map(
                              (nama) => DropdownMenuItem(
                                value: nama,
                                child: Text(
                                  nama,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                    dropdownColor: const Color(0xFF032B45),
                    onChanged: (val) {
                      setState(() {
                        _selectedPasien = val;
                      });
                    },
                    validator:
                        (val) =>
                            val == null || val.isEmpty ? "Wajib dipilih" : null,
                  ),
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
                    _tanggalController.text = DateFormat(
                      'dd MMMM yyyy',
                      'id_ID',
                    ).format(picked);
                  }
                },
                decoration: _inputDecoration("Tanggal Mulai"),
                style: const TextStyle(color: Colors.white),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Tanggal wajib diisi"
                            : null,
              ),
              const SizedBox(height: 16),
              _buildTextField("Durasi (mis. 14 Hari)", _durasiController),
              const SizedBox(height: 16),
              _buildTextField(
                "Nama Obat (mis. Acetaminophen)",
                _obatController,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                "Jenis Takaran Obat",
                jenisObatList,
                _jenisObat,
                (val) {
                  setState(() {
                    _jenisObat = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Frekuensi (berapa kali sehari)",
                _frekuensiController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text("Waktu Minum", style: const TextStyle(color: Colors.white)),
              ListTile(
                title: const Text(
                  "Sebelum Makan",
                  style: TextStyle(color: Colors.white),
                ),
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
                title: const Text(
                  "Sesudah Makan",
                  style: TextStyle(color: Colors.white),
                ),
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        _jenisObat != null) {
                      final data = {
                        "pasien": _selectedPasien,
                        "mulai": _tanggalController.text,
                        "durasi": _durasiController.text,
                        "obat": _obatController.text,
                        "jenisObat": _jenisObat,
                        "frekuensi": _frekuensiController.text,
                        "waktuMinum": _waktuMinum,
                        "createdAt": FieldValue.serverTimestamp(),
                      };
                      await _simpanKeFirestore(data);
                      if (mounted) {
                        await _showSuccessDialog(); // Tampilkan animasi sukses
                        Navigator.pop(context, data);
                      }
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

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF032B45),
      decoration: _inputDecoration(label),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator: (val) => val == null || val.isEmpty ? "Wajib dipilih" : null,
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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

// Widget dialog animasi sukses untuk jadwal obat
class _SuccessDialogObat extends StatefulWidget {
  const _SuccessDialogObat();

  @override
  State<_SuccessDialogObat> createState() => _SuccessDialogObatState();
}

class _SuccessDialogObatState extends State<_SuccessDialogObat>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scale;
  late Animation<double> _checkAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _scale = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _checkController.forward();
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _checkAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: (1 - _checkAnimation.value) * 1.5,
                    child: Opacity(
                      opacity: _checkAnimation.value.clamp(
                        0.0,
                        1.0,
                      ), // Perbaikan di sini
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 40 + 16 * _checkAnimation.value,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 14),
              FadeTransition(
                opacity: _fade,
                child: const Text(
                  "Jadwal obat\nberhasil disimpan!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF011D32),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
