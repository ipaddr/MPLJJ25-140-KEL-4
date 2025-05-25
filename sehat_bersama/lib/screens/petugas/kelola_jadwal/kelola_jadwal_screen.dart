import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KelolaJadwalScreen extends StatefulWidget {
  final Map<String, dynamic>? jadwal;

  const KelolaJadwalScreen({super.key, this.jadwal});

  @override
  State<KelolaJadwalScreen> createState() => _KelolaJadwalScreenState();
}

class _KelolaJadwalScreenState extends State<KelolaJadwalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _poliController = TextEditingController();
  final TextEditingController _maksPasienController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _status = 'Aktif';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final jadwal = widget.jadwal;
    if (jadwal != null) {
      _poliController.text = jadwal['poli'] ?? '';
      _tanggalController.text = jadwal['tanggal'] ?? '';
      _maksPasienController.text = jadwal['maksPasien']?.toString() ?? '';
      _catatanController.text = jadwal['catatan'] ?? '';

      if (jadwal['start'] != null && jadwal['start'] != '') {
        _startTime = from24HourString(jadwal['start']);
      }
      if (jadwal['end'] != null && jadwal['end'] != '') {
        _endTime = from24HourString(jadwal['end']);
      }

      _status = jadwal['status'] ?? 'Aktif';
    }
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _poliController.dispose();
    _maksPasienController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  String to24HourString(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  TimeOfDay from24HourString(String timeStr) {
    final dt = DateFormat('HH:mm').parse(timeStr);
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStart
              ? (_startTime ?? TimeOfDay.now())
              : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime initialDate = now;

    if (_tanggalController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd-MM-yyyy').parse(_tanggalController.text);
        if (initialDate.isBefore(DateTime(now.year, now.month, now.day))) {
          initialDate = now;
        }
      } catch (_) {
        initialDate = now;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4A9DEB),
              onPrimary: Colors.white,
              surface: Color(0xFF032B45),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFF011D32),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _simpanJadwal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = {
        'poli': _poliController.text.trim(),
        'tanggal': _tanggalController.text.trim(),
        'start': _startTime != null ? to24HourString(_startTime!) : '',
        'end': _endTime != null ? to24HourString(_endTime!) : '',
        'maksPasien': int.tryParse(_maksPasienController.text.trim()) ?? 0,
        'catatan': _catatanController.text.trim(),
        'status': _status,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.jadwal == null) {
        await FirebaseFirestore.instance.collection('penjadwalan').add(result);
      } else {
        final docId = widget.jadwal!['id'];
        if (docId != null) {
          await FirebaseFirestore.instance
              .collection('penjadwalan')
              .doc(docId)
              .update(result);
        } else {
          throw Exception('Document ID tidak ditemukan');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil disimpan')),
        );
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan jadwal: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011D32),
      appBar: AppBar(
        title: Text(widget.jadwal == null ? "Tambah Jadwal" : "Edit Jadwal"),
        backgroundColor: const Color(0xFF032B45),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField("Poliklinik", _poliController),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isLoading ? null : _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _tanggalController,
                        decoration: _inputDecoration(
                          "Tanggal Pemeriksaan",
                        ).copyWith(
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.white70,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Wajib diisi"
                                    : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              _isLoading
                                  ? null
                                  : () => _pickTime(isStart: true),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text:
                                    _startTime != null
                                        ? to24HourString(_startTime!)
                                        : '',
                              ),
                              decoration: _inputDecoration(
                                "Jam Mulai",
                              ).copyWith(
                                suffixIcon: const Icon(
                                  Icons.access_time,
                                  color: Colors.white70,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Wajib diisi"
                                          : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              _isLoading
                                  ? null
                                  : () => _pickTime(isStart: false),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text:
                                    _endTime != null
                                        ? to24HourString(_endTime!)
                                        : '',
                              ),
                              decoration: _inputDecoration(
                                "Jam Selesai",
                              ).copyWith(
                                suffixIcon: const Icon(
                                  Icons.access_time,
                                  color: Colors.white70,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Wajib diisi"
                                          : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "Jumlah Maksimal Pasien",
                    _maksPasienController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "Catatan Tambahan",
                    _catatanController,
                    maxLines: 3,
                    isRequired: false,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: _inputDecoration("Status Jadwal"),
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF032B45),
                    items: const [
                      DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                      DropdownMenuItem(
                        value: "Nonaktif",
                        child: Text("Nonaktif"),
                      ),
                    ],
                    onChanged:
                        _isLoading
                            ? null
                            : (val) => setState(() => _status = val!),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _simpanJadwal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                "Simpan Jadwal",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF032B45),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      enabled: !_isLoading,
      validator:
          isRequired
              ? (val) =>
                  val == null || val.trim().isEmpty ? "Wajib diisi" : null
              : null,
      decoration: _inputDecoration(label),
    );
  }
}
