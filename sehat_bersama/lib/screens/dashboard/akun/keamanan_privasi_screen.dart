import 'package:flutter/material.dart';

class KeamananPrivasiScreen extends StatelessWidget {
  const KeamananPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keamanan & Privasi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Tips Keamanan Akun",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _TipsCard(
            icon: Icons.lock,
            title: "Gunakan Kata Sandi yang Kuat",
            desc:
                "Pastikan kata sandi Anda terdiri dari minimal 6 karakter, kombinasi huruf besar, kecil, angka, dan simbol.",
          ),
          _TipsCard(
            icon: Icons.visibility_off,
            title: "Jaga Kerahasiaan Kata Sandi",
            desc:
                "Jangan pernah membagikan kata sandi Anda kepada siapapun, termasuk petugas aplikasi.",
          ),
          _TipsCard(
            icon: Icons.logout,
            title: "Selalu Logout",
            desc:
                "Logout dari aplikasi setelah selesai digunakan, terutama jika menggunakan perangkat bersama.",
          ),
          _TipsCard(
            icon: Icons.privacy_tip,
            title: "Data Pribadi Aman",
            desc:
                "Data Anda hanya digunakan untuk keperluan pelayanan kesehatan dan tidak dibagikan ke pihak lain.",
          ),
          const SizedBox(height: 24),
          const Text(
            "Pengaturan Privasi",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: true,
            onChanged: (v) {},
            title: const Text("Izinkan Notifikasi"),
            subtitle: const Text(
              "Aktifkan untuk menerima info penting dari aplikasi.",
            ),
            activeColor: Colors.blue,
          ),
          SwitchListTile(
            value: false,
            onChanged: (v) {},
            title: const Text("Sembunyikan Email dari Profil"),
            subtitle: const Text(
              "Email Anda tidak akan ditampilkan di halaman profil.",
            ),
            activeColor: Colors.blue,
          ),
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
                      "Jika Anda merasa akun Anda tidak aman, segera ubah kata sandi melalui menu Profil.",
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

class _TipsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _TipsCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[800]),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(desc, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}
