import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'medication/medication_reminder_screen.dart';
import 'registrasi/registrasi_screen.dart';
import 'antrean/layanan_antrean_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String? _userName;
  String? _userStatus;
  bool _isLoading = true;

  Map<String, dynamic>? _jadwalHariIni;
  List<String> _listNamaPasien = [];

  @override
  void initState() {
    super.initState();
    // Reset state agar data lama tidak tertinggal saat user berbeda login
    _userName = null;
    _userStatus = null;
    _jadwalHariIni = null;
    _listNamaPasien = [];
    _isLoading = true;
    _fetchDashboardData();
    _fetchNamaPasien();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Ambil nama dari koleksi users berdasarkan UID user login
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        _userName = userDoc.data()?['name'] ?? 'Pengguna';
        _userStatus = userDoc.data()?['status'] ?? 'Aktif';

        final today = DateTime.now();
        final todayStr = DateFormat('dd-MM-yyyy').format(today);

        // Ambil jadwal pemeriksaan hari ini dari koleksi penjadwalan
        final jadwalSnapshot =
            await FirebaseFirestore.instance
                .collection('penjadwalan')
                .where('tanggal', isEqualTo: todayStr)
                .get();

        Map<String, dynamic>? jadwalHariIni;
        for (var doc in jadwalSnapshot.docs) {
          final data = doc.data();
          if (data['pasien'] == null || data['pasien'] == _userName) {
            jadwalHariIni = data;
            break;
          }
        }
        jadwalHariIni ??=
            jadwalSnapshot.docs.isNotEmpty
                ? jadwalSnapshot.docs.first.data()
                : null;
        _jadwalHariIni = jadwalHariIni;
      } catch (e) {
        _userName = 'Pengguna';
        _userStatus = 'Gagal memuat';
        _jadwalHariIni = null;
      }
    } else {
      _userName = 'Pengguna';
      _userStatus = 'Tidak Login';
      _jadwalHariIni = null;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchNamaPasien() async {
    try {
      final regSnapshot =
          await FirebaseFirestore.instance
              .collection('registrasi_online')
              .get();
      setState(() {
        _listNamaPasien =
            regSnapshot.docs
                .map((doc) => doc.data()['nama']?.toString() ?? '')
                .where((nama) => nama.isNotEmpty)
                .toList();
      });
    } catch (e) {
      setState(() {
        _listNamaPasien = [];
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      if (!_isLoading) {
        _fetchDashboardData();
      }
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1) {
      Navigator.pushNamed(context, '/berita');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/chatbot');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  String _formatJadwal(Map<String, dynamic>? data) {
    if (data == null) return "Tidak ada jadwal pemeriksaan hari ini";
    final poli = data['poli'] ?? '-';
    final jam =
        (data['start'] != null && data['end'] != null)
            ? "${data['start']} - ${data['end']}"
            : '-';
    final catatan = data['catatan'] ?? '';
    return "Poli: $poli\nJam: $jam${catatan.isNotEmpty ? '\nCatatan: $catatan' : ''}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF07477C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Berita"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 70,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.business,
                        size: 70,
                        color: Colors.grey,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Hi, ${_userName ?? '...'} ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (_userStatus == 'Aktif' ||
                                        _userStatus == 'Terverifikasi')
                                      const Icon(
                                        Icons.verified,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                  ],
                                ),
                                Text(
                                  "Status: ${_userStatus ?? '...'}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tombol Notifikasi diklik!'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Menu Icon Grid
              Center(
                child: SizedBox(
                  width: 3 * 115 + 2 * 12,
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                    children: [
                      _buildMenuItem(
                        context,
                        "Registrasi Online",
                        Icons.description_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const RegistrasiOnlineScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context,
                        "Penjadwalan Pemeriksaan",
                        Icons.calendar_today_outlined,
                        onTap: () {
                          Navigator.pushNamed(context, '/penjadwalan');
                        },
                      ),
                      _buildMenuItem(
                        context,
                        "Hasil Pemeriksaan",
                        Icons.monitor_heart_outlined,
                        onTap: () {
                          if (_userName != null && _userName!.isNotEmpty) {
                            Navigator.pushNamed(
                              context,
                              '/hasil-pemeriksaan',
                              arguments: {'namaPasien': _userName},
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama pasien tidak ditemukan!'),
                              ),
                            );
                          }
                        },
                      ),
                      _buildMenuItem(
                        context,
                        "Screening TBC",
                        Icons.screen_search_desktop_outlined,
                        onTap: () {
                          Navigator.pushNamed(context, '/screening');
                        },
                      ),
                      _buildMenuItem(
                        context,
                        "Layanan Antrean",
                        Icons.groups_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const LayananAntreanScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context,
                        "Pengingat Obat",
                        Icons.medication_liquid_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const MedicationReminderScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Pemeriksaan Hari Ini
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Jadwal Pemeriksaan Hari Ini",
                            style: TextStyle(
                              color: Color(0xFF0D47A1),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                _formatJadwal(_jadwalHariIni),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                  fontSize: 15,
                                ),
                              ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 36,
                      color: Color(0xFF07477C),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Daftar Pasien Terdaftar dengan icon user besar di kanan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF07477C),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pasien Terdaftar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isLoading
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                              : _listNamaPasien.isEmpty
                              ? const Text(
                                "Belum ada pasien terdaftar.",
                                style: TextStyle(color: Colors.white),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _listNamaPasien.length,
                                itemBuilder:
                                    (context, idx) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.5,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _listNamaPasien[idx],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.supervised_user_circle_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String label,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF07477C),
              radius: 28,
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
