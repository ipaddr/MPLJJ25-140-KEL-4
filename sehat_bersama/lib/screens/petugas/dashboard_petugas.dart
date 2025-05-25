import 'package:flutter/material.dart';

class DashboardPetugasScreen extends StatelessWidget {
  final VoidCallback? onLogout;
  const DashboardPetugasScreen({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011D32),
      appBar: AppBar(
        backgroundColor: const Color(0xFF032B45),
        elevation: 0,
        title: const Text(
          "Dashboard Petugas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: onLogout ??
                () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login-petugas',
                    (route) => false,
                  );
                },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo_putih.png',
                  height: 100,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Dashboard Petugas",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.event_note,
                      label: "Kelola Jadwal Pemeriksaan",
                      onTap: () {
                        Navigator.pushNamed(context, '/list-jadwal');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      context,
                      icon: Icons.cloud_upload,
                      label: "Upload Hasil Pemeriksaan",
                      onTap: () {
                        Navigator.pushNamed(context, '/input-hasil');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      context,
                      icon: Icons.medical_services,
                      label: "Kelola Jadwal Obat Pasien",
                      onTap: () {
                        Navigator.pushNamed(context, '/kelola-obat');
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onLogout ??
                        () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login-petugas',
                            (route) => false,
                          );
                        },
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
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 600,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF032B45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF4A9DEB), size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}