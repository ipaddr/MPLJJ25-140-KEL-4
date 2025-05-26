import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LayananAntreanScreen extends StatefulWidget {
  const LayananAntreanScreen({super.key});

  @override
  State<LayananAntreanScreen> createState() => _LayananAntreanScreenState();
}

class _LayananAntreanScreenState extends State<LayananAntreanScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _antreanList = [];
  List<String> _daftarPasien = [];
  String? _pasienDipilih;

  @override
  void initState() {
    super.initState();
    _fetchDaftarPasien().then((_) => _fetchAntrean());
  }

  Future<void> _fetchDaftarPasien() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('antrean').get();
      final pasienSet = <String>{};
      for (var doc in snapshot.docs) {
        final nama = doc.data()['namaPasien'];
        if (nama != null && nama.toString().trim().isNotEmpty) {
          pasienSet.add(nama);
        }
      }
      setState(() {
        _daftarPasien = pasienSet.toList()..sort();
        if (_daftarPasien.isNotEmpty &&
            (_pasienDipilih == null ||
                !_daftarPasien.contains(_pasienDipilih))) {
          _pasienDipilih = _daftarPasien.first;
        }
      });
    } catch (e) {
      setState(() {
        _daftarPasien = [];
      });
    }
  }

  Future<void> _fetchAntrean() async {
    setState(() {
      _loading = true;
    });
    try {
      if (_pasienDipilih != null) {
        final antreanQuery =
            await FirebaseFirestore.instance
                .collection('antrean')
                .where('namaPasien', isEqualTo: _pasienDipilih)
                .orderBy('waktuDibuat', descending: true)
                .get();

        List<Map<String, dynamic>> antreanData = [];
        for (var doc in antreanQuery.docs) {
          Map<String, dynamic> data = doc.data();
          data['docId'] = doc.id;
          antreanData.add(data);
        }
        setState(() {
          _antreanList = antreanData;
        });
      } else {
        setState(() {
          _antreanList = [];
        });
      }
    } catch (e) {
      setState(() {
        _antreanList = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat antrean: $e')));
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _refreshAll() async {
    await _fetchDaftarPasien();
    await _fetchAntrean();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF07477C),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Pelayanan Antrean"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          color: Color(0xFF07477C),
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF07477C)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshAll),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_daftarPasien.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButton<String>(
                    value: _pasienDipilih,
                    isExpanded: true,
                    items:
                        _daftarPasien
                            .map(
                              (nama) => DropdownMenuItem(
                                value: nama,
                                child: Text(nama),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _pasienDipilih = value;
                      });
                      _fetchAntrean();
                    },
                  ),
                ),
              Expanded(
                child:
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _antreanList.isEmpty
                        ? _buildEmptyAntreanCard()
                        : ListView(
                          children:
                              _antreanList
                                  .map(
                                    (antrean) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: _buildAntreanCard(
                                        context,
                                        antrean: antrean,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAntreanCard(
    BuildContext context, {
    required Map<String, dynamic> antrean,
  }) {
    final namaPasien = antrean['namaPasien'] ?? '-';
    final poli = antrean['poli'] ?? '-';
    final tanggal = antrean['tanggal'] ?? '-';
    final jam =
        "${antrean['jamMulai'] ?? '-'} - ${antrean['jamSelesai'] ?? '-'}";
    final nomorAntrean = antrean['nomorAntrean'] ?? '-';
    final status = antrean['statusAntrean'] ?? '-';
    final namaDokter = antrean['namaDokter'] ?? '-';
    final kodeBooking = antrean['kodeBooking'] ?? '-';
    final estimasiLayanan = antrean['estimasiLayanan'] ?? '-';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF07477C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      nomorAntrean,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaPasien,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF07477C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text("Poli: $poli", style: const TextStyle(fontSize: 15)),
                      Text(
                        "Dokter: $namaDokter",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Tanggal: $tanggal",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text("Jam: $jam", style: const TextStyle(fontSize: 14)),
                      Text(
                        "Kode Booking: $kodeBooking",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Estimasi: $estimasiLayanan",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Status: $status",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/cetak-antrean',
                      arguments: antrean,
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text("Cetak"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5B99),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAntreanCard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "Ambil\nNo\nAntrean",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Belum Ada Antrean",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("Silakan buat jadwal pemeriksaan"),
                        Text("terlebih dahulu untuk mendapatkan"),
                        Text("nomor antrean."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 20),
              label: const Text(
                "Buat Jadwal Pemeriksaan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07477C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, '/penjadwalan'),
            ),
          ),
        ],
      ),
    );
  }
}
