import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'kelola_jadwal_screen.dart';

class JadwalListScreen extends StatefulWidget {
  const JadwalListScreen({super.key});

  @override
  State<JadwalListScreen> createState() => _JadwalListScreenState();
}

class _JadwalListScreenState extends State<JadwalListScreen> {
  List<Map<String, dynamic>> jadwalList = [];

  @override
  void initState() {
    super.initState();
    // Tambahkan jadwal awal jika perlu
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final now = TimeOfDay.now();

    final todayList = jadwalList.where((j) => j['tanggal'] == today).toList();
    final upcomingList = jadwalList.where((j) => j['tanggal'] != today && _isAfterToday(j['tanggal'])).toList();
    final historyList = jadwalList.where((j) => !_isAfterToday(j['tanggal']) && j['tanggal'] != today).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF011D32),
      appBar: AppBar(
        title: const Text('Daftar Jadwal Pemeriksaan'),
        backgroundColor: const Color(0xFF032B45),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A9DEB),
        onPressed: () async {
          final newJadwal = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KelolaJadwalScreen(),
            ),
          );
          if (newJadwal != null) {
            setState(() {
              jadwalList.add(newJadwal);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSection("Hari Ini", todayList, canEdit: false),
            _buildSection("Mendatang", upcomingList, canEdit: true),
            _buildSection("Riwayat", historyList, canEdit: false, showPasien: true),
          ],
        ),
      ),
    );
  }

  bool _isAfterToday(String tanggal) {
    final date = DateFormat('dd-MM-yyyy').parse(tanggal);
    return date.isAfter(DateTime.now());
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> list,
      {bool canEdit = false, bool showPasien = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...list.map((jadwal) => _buildCard(jadwal, canEdit, showPasien)).toList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> jadwal, bool canEdit, bool showPasien) {
    return Card(
      color: const Color(0xFF032B45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          '${jadwal['tanggal']} | ${jadwal['start']} - ${jadwal['end']}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          jadwal['poli'],
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KelolaJadwalScreen(jadwal: jadwal),
                    ),
                  );
                  if (updated != null) {
                    setState(() {
                      final index = jadwalList.indexOf(jadwal);
                      jadwalList[index] = updated;
                    });
                  }
                },
              )
            : null,
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: const Color(0xFF032B45),
              title: const Text("Detail Jadwal", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Poli: ${jadwal['poli']}", style: const TextStyle(color: Colors.white)),
                  Text("Tanggal: ${jadwal['tanggal']}", style: const TextStyle(color: Colors.white)),
                  Text("Jam: ${jadwal['start']} - ${jadwal['end']}", style: const TextStyle(color: Colors.white)),
                  Text("Maks Pasien: ${jadwal['maksPasien']}", style: const TextStyle(color: Colors.white)),
                  Text("Catatan: ${jadwal['catatan']}", style: const TextStyle(color: Colors.white)),
                  if (showPasien) const Text("Pasien: (daftar dummy)", style: TextStyle(color: Colors.white)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
