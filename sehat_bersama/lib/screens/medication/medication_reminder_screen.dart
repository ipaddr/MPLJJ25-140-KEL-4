import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  final String name;
  final String dosage;
  final String instructions;
  final String medicationType;
  final TimeOfDay time;
  final String schedule;
  bool isCompleted;

  Medication({
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.medicationType,
    required this.time,
    required this.schedule,
    this.isCompleted = false,
  });
}

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({Key? key}) : super(key: key);

  @override
  State<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  final List<Medication> _medications = [
    Medication(
      name: 'Acetaminophen',
      dosage: '1 tablet',
      instructions: 'Sebelum Makan',
      medicationType: 'Pill',
      time: const TimeOfDay(hour: 8, minute: 0),
      schedule: 'Setiap Hari',
      isCompleted: true,
    ),
    Medication(
      name: 'Paracetamol',
      dosage: '1 tablet',
      instructions: 'Sebelum Makan',
      medicationType: 'Pill',
      time: const TimeOfDay(hour: 8, minute: 30),
      schedule: 'Setiap Hari',
      isCompleted: true,
    ),
    Medication(
      name: 'Rhinocs SG',
      dosage: '1 tablet',
      instructions: 'Sebelum Makan',
      medicationType: 'Pill',
      time: const TimeOfDay(hour: 16, minute: 30),
      schedule: 'Setiap Hari',
      isCompleted: false,
    ),
  ];

  DateTime _selectedDate = DateTime.now();
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    if (mounted) {
      setState(() {
        _isLocaleInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized) {
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
        onPressed: () {
          _navigateToAddMedication(context);
        },
        backgroundColor: const Color(0xFF07477C),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF07477C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            _navigateToAddMedication(context);
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
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToAddMedication(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddMedicationFlow()));

    if (result != null && result is Medication) {
      setState(() {
        _medications.add(result);
      });
    }
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Medication data
  String _medicationName = '';
  String _medicationType = '';
  String _schedule = '';
  int _hours = 8;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage++;
    });
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage--;
    });
  }

  void _finishFlow() {
    final newMedication = Medication(
      name: _medicationName,
      dosage:
          '1 tablet', // Default value, could be customized in a future screen
      instructions: 'Sebelum Makan', // Default value, could be customized
      medicationType: _medicationType,
      time: TimeOfDay(hour: _hours, minute: _minutes),
      schedule: _schedule,
    );

    Navigator.of(context).pop(newMedication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF07477C)),
          onPressed: () {
            if (_currentPage > 0) {
              _previousPage();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Page 1: Add Medication Name
          _buildAddMedicationNamePage(),

          // Page 2: Select Medication Type
          _buildSelectMedicationTypePage(),

          // Page 3: Select Schedule
          _buildSelectSchedulePage(),

          // Page 4: Select Time
          _buildSelectTimePage(),
        ],
      ),
    );
  }

  Widget _buildAddMedicationNamePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Obat apa yang ingin anda tambah?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Nama obat',
              ),
              onChanged: (value) {
                setState(() {
                  _medicationName = value;
                });
              },
            ),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: _medicationName.isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07477C),
                minimumSize: const Size(120, 40),
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectMedicationTypePage() {
    final medicationTypes = [
      'Pill',
      'Solution',
      'Injection',
      'Powder',
      'Drops',
      'Inhaler',
      'Other',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis obat yang ingin ditambah?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: medicationTypes.length,
              itemBuilder: (context, index) {
                final type = medicationTypes[index];
                return RadioListTile<String>(
                  title: Text(type),
                  value: type,
                  groupValue: _medicationType,
                  activeColor: const Color(0xFF07477C),
                  onChanged: (value) {
                    setState(() {
                      _medicationType = value!;
                    });
                  },
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _medicationType.isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07477C),
                minimumSize: const Size(120, 40),
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectSchedulePage() {
    final scheduleOptions = [
      'Setiap Hari',
      'Sekali Seminggu',
      'Dua Kali Seminggu',
      'Tiga Kali Seminggu',
      'Empat Kali Seminggu',
      'Sekali Sebulan',
      'Other',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal konsumsi obat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: scheduleOptions.length,
              itemBuilder: (context, index) {
                final option = scheduleOptions[index];
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _schedule,
                  activeColor: const Color(0xFF07477C),
                  onChanged: (value) {
                    setState(() {
                      _schedule = value!;
                    });
                  },
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _schedule.isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07477C),
                minimumSize: const Size(120, 40),
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectTimePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal konsumsi obat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeColumn(
                'Hours',
                _hours,
                (newValue) {
                  setState(() {
                    _hours = newValue;
                  });
                },
                0,
                23,
              ),
              const Text(
                ' : ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              _buildTimeColumn(
                'Minutes',
                _minutes,
                (newValue) {
                  setState(() {
                    _minutes = newValue;
                  });
                },
                0,
                59,
              ),
              const Text(
                ' : ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              _buildTimeColumn(
                'Seconds',
                _seconds,
                (newValue) {
                  setState(() {
                    _seconds = newValue;
                  });
                },
                0,
                59,
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: _finishFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07477C),
                minimumSize: const Size(120, 40),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(
    String label,
    int value,
    Function(int) onChanged,
    int min,
    int max,
  ) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 10),
        SizedBox(
          width: 60,
          child: Column(
            children: [
              _buildTimeControl(() {
                onChanged((value + 1) % (max + 1));
              }, Icons.arrow_drop_up),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTimeControl(() {
                onChanged((value - 1 + max + 1) % (max + 1));
              }, Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeControl(VoidCallback onPressed, IconData icon) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }
}
