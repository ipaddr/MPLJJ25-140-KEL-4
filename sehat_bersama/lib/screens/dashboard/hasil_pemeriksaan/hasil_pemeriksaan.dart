import 'package:flutter/material.dart';

class HasilPemeriksaanScreen extends StatelessWidget {
  const HasilPemeriksaanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);

    // Dummy data
    final hasilList = [
      {'tanggal': '12 April 2025', 'jenis': 'Pemeriksaan Darah'},
      {'tanggal': '12 Mei 2025', 'jenis': 'Pemeriksaan Darah'},
      {'tanggal': '12 Juni 2025', 'jenis': 'Pemeriksaan Darah'},
      {'tanggal': '12 Juli 2025', 'jenis': 'Pemeriksaan Darah'},
      {'tanggal': '12 Agustus 2025', 'jenis': 'Pemeriksaan Darah'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hasil Pemeriksaan',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: hasilList.length,
        itemBuilder: (context, index) {
          final item = hasilList[index];
          return _buildHasilCard(
            tanggal: item['tanggal']!,
            jenis: item['jenis']!,
            context: context,
          );
        },
      ),
    );
  }

  Widget _buildHasilCard({
    required String tanggal,
    required String jenis,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tanggal, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(jenis),
          const SizedBox(height: 12),
          Row(
            children: [
              // Tombol-tombol
              _buildOutlinedButton("Lihat Detail", () {
                // Aksi lihat detail
              }),
              const SizedBox(width: 8),
              _buildOutlinedButton("Unduh", () {
                // Aksi unduh
              }),
              const SizedBox(width: 8),
              _buildOutlinedButton("Bagikan", () {
                // Aksi bagikan
              }),
              const Spacer(),
              // Gambar thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/sample_result.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF07477C)),
        foregroundColor: const Color(0xFF07477C),
        textStyle: const TextStyle(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
