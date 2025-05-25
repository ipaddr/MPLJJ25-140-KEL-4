import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JadwalSuksesScreen extends StatefulWidget {
  final Map<String, dynamic> jadwalDipilih;
  final String namaPeserta;

  const JadwalSuksesScreen({
    super.key,
    required this.jadwalDipilih,
    required this.namaPeserta,
  });

  @override
  State<JadwalSuksesScreen> createState() => _JadwalSuksesScreenState();
}

class _JadwalSuksesScreenState extends State<JadwalSuksesScreen> {
  bool _antreanSaved = false;

  @override
  void initState() {
    super.initState();
    _simpanAntrean();
  }

  Future<void> _simpanAntrean() async {
    if (_antreanSaved) return;
    try {
      await FirebaseFirestore.instance.collection('antrean').add({
        'jadwalId': widget.jadwalDipilih['id'],
        'poli': widget.jadwalDipilih['poli'],
        'tanggal': widget.jadwalDipilih['tanggal'],
        'start': widget.jadwalDipilih['start'],
        'end': widget.jadwalDipilih['end'],
        'nama': widget.namaPeserta,
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _antreanSaved = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan antrean: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color.fromARGB(255, 255, 255, 255);
    const primaryColor = Color(0xFF07477C);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                "Penjadwalan Pemeriksaan\nBerhasil!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 10, 10, 10),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama: ${widget.namaPeserta}",
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // diperbesar
                      ),
                    ),
                    Text(
                      "Poli: ${widget.jadwalDipilih['poli']}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 17, // diperbesar
                      ),
                    ),
                    Text(
                      "Tanggal: ${widget.jadwalDipilih['tanggal']}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 17, // diperbesar
                      ),
                    ),
                    Text(
                      "Jam: ${widget.jadwalDipilih['start']} - ${widget.jadwalDipilih['end']}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 17, // diperbesar
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                "Silakan menuju ke Rumah Sakit\nsesuai jadwal yang tertera.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                ), // diperbesar & warna lebih gelap
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home, size: 20),
                  label: const Text(
                    "Kembali ke Menu Utama",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed:
                      () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/dashboard',
                        (route) => false,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
