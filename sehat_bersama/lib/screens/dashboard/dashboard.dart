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

  Map<String, dynamic>? _appointmentData;
  Map<String, dynamic>? _medicationData;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        _userName = userDoc.data()?['name'] ?? 'Pengguna';
        _userStatus = userDoc.data()?['status'] ?? 'Aktif';

        final appointmentQuery =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('appointments')
                .orderBy('dateTime', descending: false)
                .limit(1)
                .get();

        if (appointmentQuery.docs.isNotEmpty) {
          _appointmentData = appointmentQuery.docs.first.data();
        } else {
          _appointmentData = null;
        }

        final medicationQuery =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('medications')
                .orderBy('reminderTime')
                .limit(1)
                .get();

        if (medicationQuery.docs.isNotEmpty) {
          _medicationData = medicationQuery.docs.first.data();
        } else {
          _medicationData = null;
        }
      } catch (e) {
        _userName = 'Pengguna';
        _userStatus = 'Gagal memuat';
        _appointmentData = null;
        _medicationData = null;
      }
    } else {
      _userName = 'Pengguna';
      _userStatus = 'Tidak Login';
      _appointmentData = null;
      _medicationData = null;
    }

    setState(() {
      _isLoading = false;
    });
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

  String _formatAppointment(Map<String, dynamic>? data) {
    if (data == null) return "Tidak ada jadwal";
    String hospitalName = data['hospitalName'] ?? 'Nama Rumah Sakit Tidak Ada';
    Timestamp? appointmentTimestamp = data['dateTime'] as Timestamp?;
    String dateTimeStr = "Tanggal tidak tersedia";

    if (appointmentTimestamp != null) {
      DateTime appointmentDateTime = appointmentTimestamp.toDate();
      dateTimeStr =
          DateFormat(
            'd MMMM yyyy, HH:mm',
            'id_ID',
          ).format(appointmentDateTime) +
          " WIB";
    }
    return "$hospitalName\n$dateTimeStr";
  }

  String _formatMedication(Map<String, dynamic>? data) {
    if (data == null) return "Tidak ada pengingat obat";
    String medicationName = data['medicationName'] ?? 'Nama Obat Tidak Ada';
    String medicationTimeStr = data['medicationTime'] ?? 'Waktu tidak tersedia';
    return "$medicationName - $medicationTimeStr";
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
                          Navigator.pushNamed(context, '/hasil');
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

              // Info Pemeriksaan
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_appointmentData != null)
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
                              "Jadwal Pemeriksaan Terdekat",
                              style: TextStyle(
                                color: Color(0xFF0D47A1),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatAppointment(_appointmentData),
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

              if (!_isLoading && _appointmentData != null)
                const SizedBox(height: 16),

              // Info Obat
              if (!_isLoading && _medicationData != null)
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
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Minum obat anda hari ini!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatMedication(_medicationData),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.medical_information_outlined,
                        size: 36,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

              if (!_isLoading && _medicationData != null)
                const SizedBox(height: 16),

              if (!_isLoading &&
                  _appointmentData == null &&
                  _medicationData == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Tidak ada jadwal pemeriksaan atau pengingat obat saat ini.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
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
