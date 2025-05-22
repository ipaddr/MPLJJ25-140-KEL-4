import 'package:flutter/material.dart';
// Pastikan path import sesuai dengan struktur folder Anda
import 'medication/medication_reminder_screen.dart';
import 'registrasi/registrasi_screen.dart'; // Asumsi ini adalah RegistrasiOnlineScreen
import 'antrean/layanan_antrean_screen.dart';
// Tidak perlu import ChatbotScreen di sini jika menggunakan Navigator.pushNamed
// dan rutenya sudah terdaftar di main.dart

class DashboardScreen extends StatefulWidget { // Mengubah menjadi StatefulWidget
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Untuk melacak item yang dipilih di BottomNavigationBar

  // Daftar widget untuk ditampilkan berdasarkan tab yang dipilih (jika ada)
  // Untuk kasus ini, semua navigasi bottom bar membuka halaman baru,
  // jadi _widgetOptions mungkin tidak langsung digunakan untuk mengganti body.
  // Namun, _selectedIndex tetap berguna untuk currentIndex BottomNavigationBar.
  // static final List<Widget> _widgetOptions = <Widget>[
  //   DashboardHomeContent(), // Konten utama dashboard Anda (jika Home tidak memuat ulang seluruh DashboardScreen)
  //   BeritaScreen(), // Jika Berita adalah bagian dari body Dashboard
  //   ChatbotScreen(), // Tidak ditampilkan di sini karena navigasi ke halaman penuh
  //   ProfileScreen(), // Tidak ditampilkan di sini karena navigasi ke halaman penuh
  // ];

  void _onItemTapped(int index) {
    if (index == 0) {
      // Jika Home adalah tampilan saat ini dan tidak perlu navigasi,
      // cukup update state jika diperlukan.
      // Jika DashboardScreen sendiri adalah "Home", maka tidak perlu aksi khusus
      // selain memperbarui _selectedIndex.
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1) {
      // Navigasi ke halaman Berita
      Navigator.pushNamed(context, '/berita');
      ;
      // Jika Berita adalah halaman penuh, Anda tidak perlu setState setelah navigasi
      // setState(() {
      //   _selectedIndex = index; // Hanya jika Berita adalah bagian dari body DashboardScreen
      // });
    } else if (index == 2) {
      // Navigasi ke halaman Chatbot
      Navigator.pushNamed(context, '/chatbot');
      // Tidak perlu setState untuk _selectedIndex di sini karena kita pindah halaman
      // dan saat kembali, DashboardScreen akan rebuild dengan _selectedIndex yang terakhir (jika diinginkan)
      // atau Anda bisa membiarkan _selectedIndex tetap pada tab sebelumnya saat kembali.
      // Untuk konsistensi visual saat kembali, mungkin lebih baik tidak mengubah _selectedIndex di sini
      // kecuali jika Anda ingin tab Chat menjadi aktif setelah kembali.
    } else if (index == 3) {
      // Navigasi ke halaman Profile
      Navigator.pushNamed(context, '/profile');
    }
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"), // index 0
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Berita"), // index 1
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"), // index 2
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"), // index 3
        ],
        currentIndex: _selectedIndex, // Gunakan _selectedIndex di sini
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
                    errorBuilder: (context, error, stackTrace) { // Penanganan error jika gambar gagal dimuat
                      return const Icon(Icons.business, size: 70, color: Colors.grey);
                    },
                  ),
                  const SizedBox(width: 12),
                  const Expanded( // Data pengguna bisa diambil dari UserProvider jika sudah login
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Hi, Susi ", // Idealnya nama pengguna dinamis
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                            Icon(Icons.verified, color: Colors.green, size: 18),
                          ],
                        ),
                        Text(
                          "Semua Keluarga Anda Terlindungi (Aktif)", // Status dinamis
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined), // Ikon notifikasi
                    onPressed: () {
                      // Aksi untuk tombol notifikasi
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tombol Notifikasi diklik!')),
                      );
                    },
                  )
                ],
              ),

              const SizedBox(height: 24),

              // Menu Icon Grid
              Center(
                child: SizedBox(
                  // Pertimbangkan menggunakan MediaQuery untuk lebar yang lebih responsif
                  // Contoh: width: MediaQuery.of(context).size.width * 0.9,
                  width: 3 * 115 + 2 * 12, // Kalkulasi ini mungkin perlu disesuaikan
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
                          // Menggunakan pushNamed jika rute '/registrasi-online' sudah ada di main.dart
                          // Navigator.pushNamed(context, '/registrasi-online');
                          // Atau tetap menggunakan MaterialPageRoute jika belum
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegistrasiOnlineScreen(), // Pastikan RegistrasiOnlineScreen ada
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
                        Icons.screen_search_desktop_outlined, // Ikon yang mungkin lebih relevan
                        onTap: () {
                          Navigator.pushNamed(context, '/screening');
                        },
                      ),
                      _buildMenuItem(
                        context,
                        "Pendaftaran Layanan (Antrean)",
                        Icons.groups_outlined, // Ikon yang mungkin lebih relevan
                        onTap: () {
                          // Navigator.pushNamed(context, '/layanan-antrean'); // Jika rute ada
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LayananAntreanScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context,
                        "Pengingat Obat",
                        Icons.medication_liquid_outlined, // Ikon yang mungkin lebih relevan
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MedicationReminderScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Pemeriksaan (Contoh data statis, idealnya dinamis)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), // Warna biru muda yang lebih soft
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // Agar teks bisa wrap jika panjang
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Jadwal Pemeriksaan Terdekat", style: TextStyle(color: Color(0xFF0D47A1), fontSize: 13)),
                          SizedBox(height: 4),
                          Text(
                            "RS Sehat Bersama\n29 April 2025, 10:00 WIB", // Tambahkan jam jika ada
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1), // Biru tua untuk teks penting
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.calendar_month_outlined, size: 36, color: Color(0xFF07477C)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info Obat (Contoh data statis, idealnya dinamis)
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Minum obat anda hari ini!",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Acetaminophen - 08:00 WIB", // Format lebih jelas
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.medical_information_outlined, size: 36, color: Colors.white),
                  ],
                ),
              ),

              const SizedBox(height: 16), // Spasi tambahan di akhir
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
      child: Container( // Memberikan sedikit padding dan dekorasi jika diinginkan
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          // color: Colors.grey[100], // Latar belakang ringan untuk item menu
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF07477C),
              radius: 28, // Sedikit lebih kecil agar tidak terlalu dominan
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: Colors.black87), // Ukuran font sedikit disesuaikan
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}