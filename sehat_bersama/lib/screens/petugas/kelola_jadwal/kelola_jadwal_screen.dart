import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    final jadwal = widget.jadwal;
    if (jadwal != null) {
      _poliController.text = jadwal['poli'] ?? '';
      _tanggalController.text = jadwal['tanggal'] ?? '';
      _maksPasienController.text = jadwal['maksPasien']?.toString() ?? '';
      _catatanController.text = jadwal['catatan'] ?? '';
      _startTime = jadwal['start'] != null && jadwal['start'] != ''
          ? from24HourString(jadwal['start'])
          : null;
      _endTime = jadwal['end'] != null && jadwal['end'] != ''
          ? from24HourString(jadwal['end'])
          : null;
      _status = jadwal['status'] ?? 'Aktif';
    }
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
      initialTime: TimeOfDay.now(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011D32),
      appBar: AppBar(
        title: const Text("Kelola Jadwal Pemeriksaan"),
        backgroundColor: const Color(0xFF032B45),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Poliklinik", _poliController),
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
                    _tanggalController.text = DateFormat('dd-MM-yyyy').format(picked);
                  }
                },
                decoration: _inputDecoration("Tanggal Pemeriksaan"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(isStart: true),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: _inputDecoration("Jam Mulai"),
                          controller: TextEditingController(
                            text: _startTime != null ? to24HourString(_startTime!) : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(isStart: false),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: _inputDecoration("Jam Selesai"),
                          controller: TextEditingController(
                            text: _endTime != null ? to24HourString(_endTime!) : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField("Jumlah Maksimal Pasien", _maksPasienController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField("Catatan Tambahan", _catatanController, maxLines: 2),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: _inputDecoration("Status Jadwal"),
                items: const [
                  DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                  DropdownMenuItem(value: "Nonaktif", child: Text("Nonaktif")),
                ],
                onChanged: (val) {
                  setState(() {
                    _status = val!;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final result = {
                        'poli': _poliController.text,
                        'tanggal': _tanggalController.text,
                        'start': _startTime != null ? to24HourString(_startTime!) : '',
                        'end': _endTime != null ? to24HourString(_endTime!) : '',
                        'maksPasien': int.tryParse(_maksPasienController.text) ?? 0,
                        'catatan': _catatanController.text,
                        'status': _status,
                      };

                      Navigator.pop(context, result);
                    }
                  },
                  child: const Text("Simpan Jadwal"),
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
