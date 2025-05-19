import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PenjadwalanScreen extends StatefulWidget {
  const PenjadwalanScreen({super.key});

  @override
  State<PenjadwalanScreen> createState() => _PenjadwalanScreenState();
}

class _PenjadwalanScreenState extends State<PenjadwalanScreen> {
  bool hasJadwal = true;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Penjadwalan Pemeriksaan"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Peserta", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            initialValue: "Susi (00000000000000000000)",
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),

          if (hasJadwal) _buildAktifCard(context) else _buildKalenderSection(),
        ],
      ),
    );
  }

  Widget _buildAktifCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF07477C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "TB00002-003",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("RS Sehat Bersama", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("No. Rujukan: 0020TB00542314456..."),
                  const SizedBox(height: 4),
                  const Text("• Tuberkulosis"),
                  const Text("Dijadwal: 29 April 2025"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() => hasJadwal = false); // simulasi ubah
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                        child: const Text("Ubah"),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() => hasJadwal = false);
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text("Batalkan"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKalenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar(
          focusedDay: selectedDate,
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 60)),
          onDaySelected: (day, _) => setState(() => selectedDate = day),
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
        ),
        const SizedBox(height: 16),
        const Text("Pilih Lokasi Pemeriksaan", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        _buildLokasiCard("RS Sehat Bersama", "Jl. Sehat Bahagia No.77, Padang"),
        const SizedBox(height: 10),
        _buildLokasiCard("Klinik Sehat", "Jl. Sehat Bahagia No.77, Padang"),
        const SizedBox(height: 10),
        _buildLokasiCard("RS Sehat Bahagia", "Jl. Sehat Bahagia No.77, Padang"),
      ],
    );
  }

  Widget _buildLokasiCard(String title, String address) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text("⏰ 08.00 - 17.00 WIB"),
            Text("📍 $address"),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/jadwal-sukses');
        },
      ),
    );
  }
}
