import 'package:flutter/material.dart';

class PanduanAplikasiScreen extends StatelessWidget {
  const PanduanAplikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_PanduanItem> panduanList = [
      _PanduanItem(
        icon: Icons.person_add_alt_1,
        title: "Registrasi Akun",
        desc:
            "Daftarkan diri Anda dengan data yang valid pada menu registrasi. Pastikan email dan NIK benar agar proses verifikasi berjalan lancar.",
      ),
      _PanduanItem(
        icon: Icons.login,
        title: "Login",
        desc:
            "Masuk ke aplikasi menggunakan email dan kata sandi yang telah didaftarkan. Jika lupa kata sandi, gunakan fitur 'Lupa Kata Sandi'.",
      ),
      _PanduanItem(
        icon: Icons.assignment,
        title: "Input & Lihat Hasil Pemeriksaan",
        desc:
            "Petugas dapat menginput hasil pemeriksaan pasien. Pasien dapat melihat riwayat hasil pemeriksaan pada menu Riwayat Pemeriksaan.",
      ),
      _PanduanItem(
        icon: Icons.medical_services,
        title: "Kelola Obat",
        desc:
            "Petugas dapat menambah, mengedit, dan menghapus data obat pada menu Kelola Obat.",
      ),
      _PanduanItem(
        icon: Icons.lock,
        title: "Ubah Kata Sandi",
        desc:
            "Ganti kata sandi Anda secara berkala melalui menu Profil > Ubah Kata Sandi untuk menjaga keamanan akun.",
      ),
      _PanduanItem(
        icon: Icons.help_outline,
        title: "Bantuan",
        desc:
            "Jika mengalami kendala, hubungi admin atau gunakan fitur bantuan pada menu Profil.",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Aplikasi'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Selamat datang di aplikasi Sehat Bersama!\n\nBerikut beberapa panduan penggunaan aplikasi untuk memudahkan Anda:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 18),
          ...panduanList.map((item) => _PanduanCard(item: item)).toList(),
          const SizedBox(height: 24),
          Card(
            color: Colors.blue[50],
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Pastikan selalu logout setelah selesai menggunakan aplikasi untuk menjaga keamanan data Anda.",
                      style: TextStyle(fontSize: 15, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanduanItem {
  final IconData icon;
  final String title;
  final String desc;
  _PanduanItem({required this.icon, required this.title, required this.desc});
}

class _PanduanCard extends StatelessWidget {
  final _PanduanItem item;
  const _PanduanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(item.icon, color: Colors.blue[800]),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(item.desc, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
