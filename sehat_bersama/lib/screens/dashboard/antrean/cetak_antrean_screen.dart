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
  int? _maksPasien;

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
      _fetchMaksPasien(_antrean?['jadwalId']);
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchMaksPasien(String? jadwalId) async {
    if (jadwalId == null) return;
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('penjadwalan')
              .doc(jadwalId)
              .get();
      if (doc.exists && mounted) {
        setState(() {
          _maksPasien = int.tryParse(
            doc.data()?['maksPasien']?.toString() ?? '0',
          );
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil maksPasien: $e');
    }
  }

  Future<void> _showSuccessDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _CheckinSuccessDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
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
        await _showSuccessDialog();
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

    // Hitung peserta dilayani dan sisa antrean
    int pesertaDilayani =
        int.tryParse(_antrean?['pesertaDilayani']?.toString() ?? '0') ?? 0;
    int sisaAntrean =
        (_maksPasien != null)
            ? (_maksPasien! - pesertaDilayani)
            : int.tryParse(_antrean?['sisaAntrean']?.toString() ?? '0') ?? 0;

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
                        value: sisaAntrean.toString(),
                      ),
                      _StatBox(
                        icon: Icons.person,
                        label: "Peserta Dilayani",
                        value: pesertaDilayani.toString(),
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

// Animasi dialog sukses check-in
class _CheckinSuccessDialog extends StatefulWidget {
  const _CheckinSuccessDialog();

  @override
  State<_CheckinSuccessDialog> createState() => _CheckinSuccessDialogState();
}

class _CheckinSuccessDialogState extends State<_CheckinSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scale;
  late Animation<double> _checkAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _scale = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _checkController.forward();
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _checkAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: (1 - _checkAnimation.value) * 1.5,
                    child: Opacity(
                      opacity: _checkAnimation.value.clamp(0.0, 1.0),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 40 + 16 * _checkAnimation.value,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 14),
              FadeTransition(
                opacity: _fade,
                child: const Text(
                  "Check-in\nberhasil!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF011D32),
                    letterSpacing: 0.5,
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
