import 'package:flutter/material.dart';

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
                      _buildMenuItem("Registrasi Online", Icons.description),
                      _buildMenuItem("Penjadwalan Pemeriksaan", Icons.calendar_today),
                      _buildMenuItem("Hasil Pemeriksaan", Icons.monitor_heart),
                      _buildMenuItem("Screening TBC", Icons.fit_screen),
                      _buildMenuItem("Pendaftaran Layanan (Antrean)", Icons.volunteer_activism),
                      _buildMenuItem("Pengingat Obat", Icons.medical_services,),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
/*
              // Info Pemeriksaan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E1F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Jadwal Pemeriksaan Terdekat"),
                        Text(
                          "RS Sehat Bersama\n29 April 2025",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.calendar_today, size: 32, color: Color(0xFF07477C)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Info Obat
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF07477C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Minum obat anda hari ini!",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Acetaminophen\n08 : 00",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    Icon(Icons.lock, size: 32, color: Colors.white),
                  ],
                ),
              ), */

              const SizedBox(height: 16),

              // Banner
            //  ClipRRect(
              //  borderRadius: BorderRadius.circular(12),
                //child: Image.asset(
                  //'assets/images/banner_tbc.png',
                 // fit: BoxFit.cover,
              //  ),
           //   ), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String label, IconData icon) {
    return InkWell(
      onTap: () {},
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
