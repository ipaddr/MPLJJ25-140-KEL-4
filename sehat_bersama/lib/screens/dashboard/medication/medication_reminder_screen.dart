import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MedicationApp());
}

class MedicationApp extends StatelessWidget {
  const MedicationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengingat Obat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF07477C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF07477C),
          primary: const Color(0xFF07477C),
        ),
      ),
      home: const MedicationReminderScreen(),
    );
  }
}

class Medication {
  final String patientName;
  final String name;
  final String dosage;
  final String instructions;
  final String medicationType;
  final TimeOfDay time;
  final String schedule;
  bool isCompleted;

  Medication({
    required this.patientName,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.medicationType,
    required this.time,
    required this.schedule,
    this.isCompleted = false,
  });

  factory Medication.fromFirestore(Map<String, dynamic> data) {
    final timeStr = (data['jam'] ?? '08:00').toString();
    final timeParts = timeStr.split(':');
    return Medication(
      patientName: data['pasien'] ?? '-',
      name: data['obat'] ?? '-',
      dosage: data['durasi'] ?? '-',
      instructions: data['waktuMinum'] ?? '-',
      medicationType: data['jenisObat'] ?? '-',
      time: TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 8,
        minute: int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0,
      ),
      schedule: data['frekuensi'] ?? '-',
    );
  }
}

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({Key? key}) : super(key: key);

  @override
  State<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  List<Medication> _medications = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _fetchMedications();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    if (mounted) {
      setState(() {
        _isLocaleInitialized = true;
      });
    }
  }

  Future<void> _fetchMedications() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('jadwal_obat')
            .orderBy('createdAt', descending: true)
            .get();

    setState(() {
      _medications =
          snapshot.docs
              .map((doc) => Medication.fromFirestore(doc.data()))
              .toList();
      _isLoading = false;
    });
  }

  Future<void> _hapusPengingatObat(Medication medication) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('jadwal_obat')
            .where('pasien', isEqualTo: medication.patientName)
            .where('obat', isEqualTo: medication.name)
            .where('jam', isEqualTo: _formatTimeOfDay(medication.time))
            .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    await _fetchMedications();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized || _isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _getFormattedDate(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child:
                _medications.isEmpty
                    ? const Center(
                      child: Text(
                        'Belum ada pengingat obat',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        return _buildMedicationCard(_medications[index]);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddMedicationFlow()),
          );
          if (result == true) {
            _fetchMedications();
          }
        },
        backgroundColor: const Color(0xFF07477C),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF07477C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) async {
          if (index == 1) {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddMedicationFlow(),
              ),
            );
            if (result == true) {
              _fetchMedications();
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Hari Ini',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Tambah',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 24,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.medication, color: Color(0xFF07477C)),
          ),
          const SizedBox(width: 8),
          const Text(
            'Pengingat Obat',
            style: TextStyle(
              color: Color(0xFF07477C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.patientName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF07477C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimeOfDay(medication.time),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.medication,
                        color: Color(0xFF07477C),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${medication.dosage} · ${medication.instructions}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    medication.schedule,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                medication.isCompleted
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: medication.isCompleted ? Colors.green : Colors.grey,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  medication.isCompleted = !medication.isCompleted;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Hapus',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text('Hapus pengingat obat ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                );
                if (confirm == true) {
                  await _hapusPengingatObat(medication);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pengingat obat dihapus')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final DateFormat dayFormatter = DateFormat('EEEE', 'id_ID');
    final DateFormat monthFormatter = DateFormat('MMMM', 'id_ID');

    final String dayName = dayFormatter.format(_selectedDate);
    final int day = _selectedDate.day;
    final String month = monthFormatter.format(_selectedDate);
    final int year = _selectedDate.year;

    return '$dayName, $day $month $year';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class AddMedicationFlow extends StatefulWidget {
  const AddMedicationFlow({Key? key}) : super(key: key);

  @override
  State<AddMedicationFlow> createState() => _AddMedicationFlowState();
}

class _AddMedicationFlowState extends State<AddMedicationFlow> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _obatController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  final TextEditingController _jamController = TextEditingController();
  final TextEditingController _frekuensiController = TextEditingController();

  String? _selectedPasien;
  List<String> _listPasien = [];
  bool _loadingPasien = true;

  String? _jenisObat;
  String _waktuMinum = "Sebelum Makan";
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

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

  Future<void> _simpanKeFirestore(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('jadwal_obat').add(data);
  }

  Future<void> _showSuccessDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SuccessDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void dispose() {
    _obatController.dispose();
    _durasiController.dispose();
    _jamController.dispose();
    _frekuensiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengingat Obat'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF07477C),
        elevation: 0,
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
                                    child: Text(nama),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedPasien = val;
                          });
                        },
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Wajib dipilih"
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _obatController,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        decoration: _inputDecoration("Nama Obat"),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Wajib diisi"
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _durasiController,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        decoration: _inputDecoration("Durasi (mis. 14 Hari)"),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Wajib diisi"
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _jenisObat,
                        decoration: _inputDecoration("Jenis Takaran Obat"),
                        items:
                            jenisObatList
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            _jenisObat = val;
                          });
                        },
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Wajib dipilih"
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _frekuensiController,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        decoration: _inputDecoration(
                          "Frekuensi (berapa kali sehari)",
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Wajib diisi"
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Waktu Minum",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        title: const Text("Sebelum Makan"),
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
                        title: const Text("Sesudah Makan"),
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
                      const SizedBox(height: 16),
                      Text(
                        "Jam Minum",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        title: Text(_selectedTime.format(context)),
                        trailing: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedTime = picked;
                              });
                            }
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
                                "obat": _obatController.text,
                                "durasi": _durasiController.text,
                                "jenisObat": _jenisObat,
                                "frekuensi": _frekuensiController.text,
                                "waktuMinum": _waktuMinum,
                                "jam":
                                    "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
                                "createdAt": FieldValue.serverTimestamp(),
                              };
                              await _simpanKeFirestore(data);
                              if (mounted) {
                                await _showSuccessDialog();
                                Navigator.pop(context, true);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF07477C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("Simpan"),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }
}

// Widget dialog animasi sukses
class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
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
                      opacity: _checkAnimation.value.clamp(0.0, 1.0),
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
