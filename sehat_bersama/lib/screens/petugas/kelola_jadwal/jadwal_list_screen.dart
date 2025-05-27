import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'kelola_jadwal_screen.dart';

class JadwalListScreen extends StatefulWidget {
  const JadwalListScreen({super.key});

  @override
  State<JadwalListScreen> createState() => _JadwalListScreenState();
}

class _JadwalListScreenState extends State<JadwalListScreen> {
  List<Map<String, dynamic>> jadwalList = [];
  bool _loading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealTimeListener();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _setupRealTimeListener() {
    try {
      _streamSubscription = FirebaseFirestore.instance
          .collection('penjadwalan')
          .orderBy('tanggal', descending: false)
          .snapshots()
          .listen(
            (snapshot) {
              if (!mounted) return;
              try {
                final list =
                    snapshot.docs.map((doc) {
                      final data = doc.data();
                      data['id'] = doc.id;
                      return data;
                    }).toList();
                setState(() {
                  jadwalList = list.cast<Map<String, dynamic>>();
                  _loading = false;
                  _errorMessage = null;
                });
              } catch (e) {
                debugPrint('Error processing snapshot: $e');
                setState(() {
                  _errorMessage = 'Gagal memproses data: ${e.toString()}';
                  _loading = false;
                });
              }
            },
            onError: (error) {
              debugPrint('Stream error: $error');
              if (mounted) {
                setState(() {
                  _errorMessage = 'Koneksi terputus: ${error.toString()}';
                  _loading = false;
                });
              }
            },
          );
    } catch (e) {
      debugPrint('Setup listener error: $e');
      setState(() {
        _errorMessage = 'Gagal menghubungkan ke database: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _fetchJadwal() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('penjadwalan')
          .orderBy('tanggal', descending: false)
          .get()
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      final list =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      setState(() {
        jadwalList = list.cast<Map<String, dynamic>>();
        _loading = false;
        _isRefreshing = false;
        _errorMessage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diperbarui'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: ${e.toString()}';
          _isRefreshing = false;
          _loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteJadwal(Map<String, dynamic> jadwal) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await FirebaseFirestore.instance
          .collection('penjadwalan')
          .doc(jadwal['id'])
          .delete()
          .timeout(const Duration(seconds: 30));

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus jadwal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi dialog animasi sukses
  Future<void> _showSuccessDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SuccessDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    final todayList = jadwalList.where((j) => j['tanggal'] == today).toList();
    final upcomingList =
        jadwalList
            .where((j) => j['tanggal'] != today && _isAfterToday(j['tanggal']))
            .toList();
    final historyList =
        jadwalList
            .where((j) => !_isAfterToday(j['tanggal']) && j['tanggal'] != today)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF011D32),
      appBar: AppBar(
        title: const Text(
          'Daftar Jadwal Pemeriksaan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF032B45),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon:
                _isRefreshing
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isRefreshing ? null : _fetchJadwal,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A9DEB),
        foregroundColor: Colors.white,
        onPressed: () async {
          try {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const KelolaJadwalScreen(),
              ),
            );
            if (result != null && mounted) {
              await _showSuccessDialog(); // Tampilkan dialog animasi sukses
            }
          } catch (e) {
            debugPrint('Navigation error: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gagal membuka halaman tambah jadwal'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchJadwal,
        color: Colors.white,
        backgroundColor: const Color(0xFF4A9DEB),
        child: _buildBody(todayList, upcomingList, historyList),
      ),
    );
  }

  Widget _buildBody(
    List<Map<String, dynamic>> todayList,
    List<Map<String, dynamic>> upcomingList,
    List<Map<String, dynamic>> historyList,
  ) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Memuat jadwal...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchJadwal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9DEB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (jadwalList.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          const Center(
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Belum ada jadwal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap tombol + untuk menambah jadwal baru',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildSection("Hari Ini", todayList, canEdit: false),
          _buildSection("Mendatang", upcomingList, canEdit: true),
          _buildSection(
            "Riwayat",
            historyList,
            canEdit: false,
            showPasien: true,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  bool _isAfterToday(String tanggal) {
    try {
      final date = DateFormat('dd-MM-yyyy').parse(tanggal);
      final now = DateTime.now();
      return date.isAfter(DateTime(now.year, now.month, now.day));
    } catch (e) {
      debugPrint('Date parsing error: $e');
      return false;
    }
  }

  Widget _buildSection(
    String title,
    List<Map<String, dynamic>> list, {
    bool canEdit = false,
    bool showPasien = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4A9DEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${list.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF032B45).withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              'Tidak ada jadwal ${title.toLowerCase()}',
              style: const TextStyle(
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...list.map((jadwal) => _buildCard(jadwal, canEdit, showPasien)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCard(
    Map<String, dynamic> jadwal,
    bool canEdit,
    bool showPasien,
  ) {
    final status = jadwal['status'] ?? 'Aktif';
    final isActive = status == 'Aktif';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: const Color(0xFF032B45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isActive
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: 4,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${jadwal['tanggal']} | ${jadwal['start']} - ${jadwal['end']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Poli: ${jadwal['poli']}',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Maks Pasien: ${jadwal['maksPasien']}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit) ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () async {
                    try {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => KelolaJadwalScreen(jadwal: jadwal),
                        ),
                      );
                      if (updated != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Jadwal berhasil diperbarui'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Edit navigation error: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal membuka halaman edit'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  tooltip: "Hapus Jadwal",
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: const Color(0xFF032B45),
                            title: const Text(
                              "Konfirmasi Hapus",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              "Yakin ingin menghapus jadwal ini?\nTindakan ini tidak dapat dibatalkan.",
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text(
                                  "Batal",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Hapus"),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) {
                      await _deleteJadwal(jadwal);
                    }
                  },
                ),
              ],
            ],
          ),
          onTap: () => _showDetailDialog(jadwal, showPasien),
        ),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> jadwal, bool showPasien) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF032B45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "Detail Jadwal",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Poli", jadwal['poli']),
                  _buildDetailRow("Tanggal", jadwal['tanggal']),
                  _buildDetailRow(
                    "Jam",
                    "${jadwal['start']} - ${jadwal['end']}",
                  ),
                  _buildDetailRow("Maks Pasien", "${jadwal['maksPasien']}"),
                  _buildDetailRow("Status", jadwal['status'] ?? 'Aktif'),
                  _buildDetailRow(
                    "Catatan",
                    jadwal['catatan'] ?? 'Tidak ada catatan',
                  ),
                  if (showPasien)
                    _buildDetailRow("Pasien", "(akan diimplementasi)"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Tutup",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Widget dialog animasi sukses
class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
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
                  "Jadwal berhasil\nditambahkan!",
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
