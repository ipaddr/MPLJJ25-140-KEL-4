import 'package:flutter/material.dart';


class LayananAntreanScreen extends StatelessWidget {
  const LayananAntreanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulasi data antrean
    final bool hasAntrean = true;

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Peserta",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set text color to black
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              readOnly: true,
              initialValue: "Susi (00000000000000000000)",
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),

            // Daftar antrean
            if (hasAntrean)
              _buildAntreanCard(
                context,
                kode: "TB00002-003",
                rumahSakit: "RS Sehat Bersama",
                rujukan: "0020TB00542314456...",
                tanggal: "29 April 2025",
                checkInEnabled: true,
              )
            else
              _buildEmptyAntreanCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAntreanCard(BuildContext context,
      {required String kode,
      required String rumahSakit,
      required String rujukan,
      required String tanggal,
      required bool checkInEnabled}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Kode antrean
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF07477C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  kode,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rumahSakit,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("No. Rujukan: $rujukan"),
                  const SizedBox(height: 4),
                  const Text("Check up • Tuberkulosis"),
                  Text("Dirujuk: $tanggal"),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: checkInEnabled
                  ? () {
                      Navigator.pushNamed(context, '/cetak-antrean');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F5B99),
                foregroundColor: Colors.white,
              ),
              child: const Text("Check-In"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAntreanCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Kode antrean kosong
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
                  Text("Pilih Instansi Kesehatan", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("No. Rujukan: -"),
                  Text("• -"),
                  Text("Dirujuk: Belum ada rujukan"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
