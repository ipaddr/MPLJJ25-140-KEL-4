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
  String? _nomorAntrean;
  bool _isGeneratingNumber = true;

  @override
  void initState() {
    super.initState();
    _simpanAntrean();
  }

  Future<String> _generateNomorAntrean() async {
    String kodePoli = _getKodePoli(widget.jadwalDipilih['poli']);
    DateTime now = DateTime.now();
    int timeBasedNumber =
        (now.hour * 10000 + now.minute * 100 + now.second) % 999 + 1;
    String nomorAntrean =
        '$kodePoli${timeBasedNumber.toString().padLeft(3, '0')}';
    return nomorAntrean;
  }

  String _getKodePoli(String poli) {
    switch (poli.toLowerCase()) {
      case 'poli umum':
        return 'A';
      case 'poli gigi':
        return 'B';
      case 'poli mata':
        return 'C';
      case 'poli jantung':
        return 'D';
      case 'poli kandungan':
        return 'E';
      case 'poli anak':
        return 'F';
      default:
        return 'A';
    }
  }

  int _calculateEstimatedWaitTime(int nomorUrut) {
    return (nomorUrut - 1) * 15;
  }

  String _formatEstimatedTime(String startTime, int waitMinutes) {
    try {
      final timeParts = startTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final totalMinutes = hour * 60 + minute + waitMinutes;
      final estimatedHour = (totalMinutes ~/ 60) % 24;
      final estimatedMinute = totalMinutes % 60;
      return '${estimatedHour.toString().padLeft(2, '0')}:${estimatedMinute.toString().padLeft(2, '0')}';
    } catch (e) {
      return startTime;
    }
  }

  Future<void> _simpanAntrean() async {
    if (_antreanSaved) return;

    setState(() {
      _isGeneratingNumber = true;
    });

    try {
      final nomorAntrean = await _generateNomorAntrean();
      final nomorUrut = int.tryParse(nomorAntrean.substring(1)) ?? 1;
      final waitTime = _calculateEstimatedWaitTime(nomorUrut);
      final estimatedTime = _formatEstimatedTime(
        widget.jadwalDipilih['start'],
        waitTime,
      );

      String docId =
          '${widget.jadwalDipilih['poli']}_${widget.jadwalDipilih['tanggal']}_${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance.collection('antrean').doc(docId).set({
        'jadwalId': widget.jadwalDipilih['id'],
        'poli': widget.jadwalDipilih['poli'],
        'tanggal': widget.jadwalDipilih['tanggal'],
        'jamMulai': widget.jadwalDipilih['start'],
        'jamSelesai': widget.jadwalDipilih['end'],
        'namaPasien':
            widget.namaPeserta, // PENTING: harus sama dengan query di antrean
        'nomorAntrean': nomorAntrean,
        'nomorUrut': nomorUrut,
        'kodeBooking': widget.jadwalDipilih['id'],
        'namaDokter': widget.jadwalDipilih['dokter'] ?? '-',
        'estimasiLayanan': estimatedTime,
        'statusAntrean': 'menunggu',
        'sudahCheckin': false,
        'waktuDibuat': FieldValue.serverTimestamp(),
        'tanggalDibuat': DateTime.now().toIso8601String().substring(0, 10),
        'bulanTahun':
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
      });

      setState(() {
        _nomorAntrean = nomorAntrean;
        _antreanSaved = true;
        _isGeneratingNumber = false;
      });
    } catch (e) {
      setState(() {
        _isGeneratingNumber = false;
      });
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama: ${widget.namaPeserta}",
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Poli: ${widget.jadwalDipilih['poli']}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      "Tanggal: ${widget.jadwalDipilih['tanggal']}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      "Jam: ${widget.jadwalDipilih['start']} - ${widget.jadwalDipilih['end']}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isGeneratingNumber)
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Menghasilkan nomor antrean...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_nomorAntrean != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Nomor Antrean Anda",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _nomorAntrean!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const Text(
                "Silakan menuju ke Rumah Sakit\nsesuai jadwal yang tertera.\n\nAnda dapat melakukan check-in online\nmelalui menu Layanan Antrean.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 36),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.receipt_long, size: 20),
                      label: const Text(
                        "Lihat Detail Antrean",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:
                          _antreanSaved
                              ? () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/layanan-antrean',
                                  (route) => false,
                                );
                              }
                              : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.home, size: 20),
                      label: const Text(
                        "Kembali ke Menu Utama",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}
