import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'jadwal_sukses_screen.dart';

class PenjadwalanScreen extends StatefulWidget {
  const PenjadwalanScreen({super.key});

  @override
  State<PenjadwalanScreen> createState() => _PenjadwalanScreenState();
}

class _PenjadwalanScreenState extends State<PenjadwalanScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> jadwalList = [];
  bool _loading = true;
  String? _errorMessage;

  // Untuk dropdown peserta
  List<Map<String, dynamic>> pesertaList = [];
  String? namaPeserta;

  @override
  void initState() {
    super.initState();
    _fetchJadwal();
    _fetchPesertaList();
  }

  Future<void> _fetchJadwal() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('penjadwalan')
              .orderBy('tanggal', descending: false)
              .get();

      final list =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      setState(() {
        jadwalList = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat jadwal: $e';
        _loading = false;
      });
    }
  }

  // Ambil semua peserta dari registrasi_online
  Future<void> _fetchPesertaList() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('registrasi_online')
              .orderBy('createdAt', descending: true)
              .get();

      final list =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      setState(() {
        pesertaList = list.cast<Map<String, dynamic>>();
        if (pesertaList.isNotEmpty) {
          namaPeserta = pesertaList.first['nama'];
        }
      });
    } catch (e) {
      setState(() {
        pesertaList = [];
        namaPeserta = null;
      });
    }
  }

  List<Map<String, dynamic>> getJadwalForSelectedDate() {
    final selectedStr = DateFormat('dd-MM-yyyy').format(selectedDate);
    return jadwalList.where((j) => j['tanggal'] == selectedStr).toList();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);

    return Scaffold(
      backgroundColor: Colors.white, // Ubah background menjadi putih
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
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    "Peserta",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: namaPeserta,
                    items:
                        pesertaList
                            .map(
                              (peserta) => DropdownMenuItem<String>(
                                value: peserta['nama'],
                                child: Text(
                                  peserta['nama'] ?? '-',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        namaPeserta = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    dropdownColor: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  _buildKalenderSection(),
                ],
              ),
    );
  }

  Widget _buildKalenderSection() {
    final jadwalForDate = getJadwalForSelectedDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar(
          focusedDay: selectedDate,
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 60)),
          onDaySelected: (day, _) => setState(() => selectedDate = day),
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
          calendarFormat: CalendarFormat.month,
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Color(0xFF4A9DEB),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Color(0xFF07477C),
              shape: BoxShape.circle,
            ),
            outsideDecoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            defaultDecoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            weekendDecoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            decoration: BoxDecoration(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Color(0xFF07477C),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF07477C)),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Color(0xFF07477C),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Jadwal Tersedia",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (jadwalForDate.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Tidak ada jadwal tersedia pada tanggal ini.",
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          ...jadwalForDate.map((jadwal) => _buildJadwalCard(jadwal)),
      ],
    );
  }

  Widget _buildJadwalCard(Map<String, dynamic> jadwal) {
    const primaryColor = Color(0xFF07477C);
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          jadwal['poli'] ?? '-',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Jam: ${jadwal['start']} - ${jadwal['end']}"),
            Text("Maks Pasien: ${jadwal['maksPasien']}"),
            if ((jadwal['catatan'] ?? '').toString().isNotEmpty)
              Text("Catatan: ${jadwal['catatan']}"),
          ],
        ),
        trailing: ElevatedButton(
          onPressed:
              namaPeserta == null
                  ? null
                  : () {
                    // Navigasi ke halaman sukses dan kirim data peserta & jadwal
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => JadwalSuksesScreen(
                              jadwalDipilih: jadwal,
                              namaPeserta: namaPeserta!,
                            ),
                      ),
                    );
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text("Pilih"),
        ),
      ),
    );
  }
}
