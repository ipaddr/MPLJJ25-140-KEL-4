import 'package:flutter/material.dart';
import '../screens/medication/medication_reminder_screen.dart'; // Import the medication reminder screen

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
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
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Hi, Susi ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                            Icon(Icons.verified, color: Colors.green, size: 18),
                          ],
                        ),
                        Text(
                          "Semua Keluarga Anda Terlindungi (Aktif)",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  )
                ],
              ),

              const SizedBox(height: 24),

              // Menu Icon Grid
              Center(
                child: SizedBox(
                  width: 3 * 110 + 2 * 12, // 3 items * 80 width + 2 gaps * 12 spacing
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                    children: [
                      _buildMenuItem(context, "Registrasi Online", Icons.description),
                      _buildMenuItem(context, "Penjadwalan Pemeriksaan", Icons.calendar_today),
                      _buildMenuItem(context, "Hasil Pemeriksaan", Icons.monitor_heart),
                      _buildMenuItem(context, "Screening TBC", Icons.fit_screen),
                      _buildMenuItem(context, "Pendaftaran Layanan (Antrean)", Icons.volunteer_activism),
                      _buildMenuItem(
                        context,
                        "Pengingat Obat", 
                        Icons.medical_services,
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
    IconData icon, 
    {VoidCallback? onTap}
  ) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF07477C),
            radius: 30,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}