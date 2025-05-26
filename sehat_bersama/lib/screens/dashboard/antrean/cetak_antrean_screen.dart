import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CetakAntreanScreen extends StatefulWidget {
  const CetakAntreanScreen({super.key});

  @override
  State<CetakAntreanScreen> createState() => _CetakAntreanScreenState();
}

class _CetakAntreanScreenState extends State<CetakAntreanScreen> {
  Map<String, dynamic>? _antrean;
  bool _loading = true;
  bool _checkinSuccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        _antrean = args;
        _loading = false;
        _checkinSuccess = _antrean?['sudahCheckin'] == true;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleCheckin() async {
    if (_antrean == null || _antrean?['docId'] == null) return;
    setState(() {
      _loading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('antrean')
          .doc(_antrean!['docId'])
          .update({'sudahCheckin': true, 'statusAntrean': 'checkin'});
      setState(() {
        _checkinSuccess = true;
        _antrean!['sudahCheckin'] = true;
        _antrean!['statusAntrean'] = 'checkin';
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Check-in berhasil!')));
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal check-in: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          },
        ),
        title: const Text(
          "Pelayanan Antrean",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _antrean == null
              ? const Center(
                child: Text(
                  "Belum ada antrean yang diambil.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Logo + Title
                  Column(
                    children: [
                      Image.asset('assets/images/logo.png', height: 70),
                      const SizedBox(height: 16),
                      const Text(
                        "RS Sehat Bersama",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "No. Rujukan: ${_antrean?['jadwalId'] ?? '-'}",
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _antrean?['namaDokter'] ?? _antrean?['dokter'] ?? "-",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Row
                  Column(
                    children: [
                      _InfoRow(
                        icon: Icons.local_hospital,
                        label: "Poliklinik",
                        value: _antrean?['poli'] ?? "-",
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: "Tanggal Rujukan",
                        value: _antrean?['tanggal'] ?? "-",
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.confirmation_number,
                        label: "Kode Booking",
                        value: _antrean?['kodeBooking'] ?? "-",
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(thickness: 1),

                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "Nomor Antrean\nPoliklinik",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _antrean?['nomorAntrean'] ?? "-",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatBox(
                        icon: Icons.groups,
                        label: "Sisa Antrean",
                        value: _antrean?['sisaAntrean']?.toString() ?? "-",
                      ),
                      _StatBox(
                        icon: Icons.person,
                        label: "Peserta Dilayani",
                        value: _antrean?['pesertaDilayani']?.toString() ?? "-",
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "Estimasi Dilayani",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _antrean?['estimasiDilayani'] ??
                              _antrean?['estimasiLayanan'] ??
                              "-",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Check-in Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed:
                          (_checkinSuccess || _antrean?['sudahCheckin'] == true)
                              ? null
                              : _handleCheckin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        (_checkinSuccess || _antrean?['sudahCheckin'] == true)
                            ? "Sudah Check-In"
                            : "Check-In",
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);
    return Column(
      children: [
        Icon(icon, size: 24, color: primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
