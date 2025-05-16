import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for locale initialization

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({Key? key}) : super(key: key);

  @override
  State<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  final List<MedicationReminder> _reminders = [
    MedicationReminder(
      time: const TimeOfDay(hour: 8, minute: 0),
      medication: 'Acetaminophen',
      dosage: '1 tablet',
      instructions: 'Sebelum Makan',
      isCompleted: true,
    ),
    MedicationReminder(
      time: const TimeOfDay(hour: 8, minute: 30),
      medication: 'Paracetamol',
      dosage: '1 tablet',
      instructions: 'Sebelum Makan',
      isCompleted: true,
    ),
  ];

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize date formatting for Indonesian locale
    initializeDateFormatting('id_ID', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 24),
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
            Navigator.pop(context);
          },
        ),
      ),
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
            child: ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                return _buildReminderCard(_reminders[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMedicationDialog();
        },
        backgroundColor: const Color(0xFF07477C),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF07477C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
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

  String _getFormattedDate() {
    // Using properly initialized Indonesian locale
    final DateFormat dayFormatter = DateFormat('EEEE', 'id_ID');
    final DateFormat monthFormatter = DateFormat('MMMM', 'id_ID');

    final String dayName = dayFormatter.format(_selectedDate);
    final int day = _selectedDate.day;
    final String month = monthFormatter.format(_selectedDate);
    final int year = _selectedDate.year;

    return '$dayName, $day $month $year';
  }

  Widget _buildReminderCard(MedicationReminder reminder) {
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
                    _formatTimeOfDay(reminder.time),
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
                        reminder.medication,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reminder.dosage} ${reminder.instructions}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                reminder.isCompleted
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: reminder.isCompleted ? Colors.green : Colors.grey,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  reminder.isCompleted = !reminder.isCompleted;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showAddMedicationDialog() {
    String? medicationName;
    String? dosage;
    String? instructions;
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Pengingat Obat'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Nama Obat'),
                  onChanged: (value) {
                    medicationName = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Dosis'),
                  onChanged: (value) {
                    dosage = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Instruksi'),
                  onChanged: (value) {
                    instructions = value;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      selectedTime = time;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Waktu'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatTimeOfDay(selectedTime)),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (medicationName != null &&
                    medicationName!.isNotEmpty &&
                    dosage != null &&
                    dosage!.isNotEmpty) {
                  setState(() {
                    _reminders.add(
                      MedicationReminder(
                        time: selectedTime,
                        medication: medicationName!,
                        dosage: dosage!,
                        instructions: instructions ?? '',
                        isCompleted: false,
                      ),
                    );
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

class MedicationReminder {
  final TimeOfDay time;
  final String medication;
  final String dosage;
  final String instructions;
  bool isCompleted;

  MedicationReminder({
    required this.time,
    required this.medication,
    required this.dosage,
    required this.instructions,
    this.isCompleted = false,
  });
}
