import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HasilPemeriksaanScreen extends StatefulWidget {
  const HasilPemeriksaanScreen({super.key});

  @override
  State<HasilPemeriksaanScreen> createState() => _HasilPemeriksaanScreenState();
}

class _HasilPemeriksaanScreenState extends State<HasilPemeriksaanScreen> {
  String? _selectedPasien;
  List<String> _listPasien = [];
  bool _loadingPasien = true;

  @override
  void initState() {
    super.initState();
    _fetchPasien();
  }

  Future<void> _fetchPasien() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('registrasi_online')
              .get();
      setState(() {
        _listPasien =
            snapshot.docs
                .map((doc) => doc.data()['nama']?.toString() ?? '')
                .where((nama) => nama.isNotEmpty)
                .toList();
        _loadingPasien = false;
      });
    } catch (e) {
      setState(() => _loadingPasien = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data pasien: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);
    const backgroundColor = Color(0xFFF4F7F9);
    const cardColor = Colors.white;
    const textColorPrimary = Color(0xFF333333);
    const textColorSecondary = Color(0xFF555555);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 1,
        title: const Text(
          'Riwayat Pemeriksaan',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _loadingPasien
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedPasien,
                      decoration: InputDecoration(
                        labelText: "Pilih Pasien",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items:
                          _listPasien
                              .map(
                                (nama) => DropdownMenuItem(
                                  value: nama,
                                  child: Text(nama),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedPasien = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child:
                          _selectedPasien == null
                              ? const Center(
                                child: Text(
                                  "Silakan pilih pasien untuk melihat hasil pemeriksaan.",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                              : StreamBuilder<QuerySnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection('hasil_pemeriksaan')
                                        .where(
                                          'namaPasien',
                                          isEqualTo: _selectedPasien,
                                        )
                                        .orderBy('tanggal', descending: true)
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        'Terjadi kesalahan: ${snapshot.error}',
                                      ),
                                    );
                                  }

                                  final docs = snapshot.data?.docs ?? [];
                                  if (docs.isEmpty) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.folder_open_outlined,
                                              size: 80,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              'Belum Ada Hasil Pemeriksaan',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: textColorPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tidak ditemukan riwayat hasil pemeriksaan untuk pasien "${_selectedPasien!}".',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: textColorSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    itemCount: docs.length,
                                    separatorBuilder:
                                        (context, index) =>
                                            const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final data =
                                          docs[index].data()
                                              as Map<String, dynamic>;

                                      // Handle tanggal bisa Timestamp atau String
                                      String tanggalPemeriksaanStr =
                                          'Data Tanggal Tidak Ada';
                                      if (data['tanggal'] != null &&
                                          data['tanggal'] is Timestamp) {
                                        try {
                                          final dateTimePemeriksaan =
                                              (data['tanggal'] as Timestamp)
                                                  .toDate();
                                          tanggalPemeriksaanStr = DateFormat(
                                            'EEEE, dd MMMM yyyy',
                                            'id_ID',
                                          ).format(dateTimePemeriksaan);
                                        } catch (e) {
                                          final dateTimePemeriksaan =
                                              (data['tanggal'] as Timestamp)
                                                  .toDate();
                                          tanggalPemeriksaanStr = DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(dateTimePemeriksaan);
                                        }
                                      } else if (data['tanggal'] != null &&
                                          data['tanggal'] is String) {
                                        tanggalPemeriksaanStr = data['tanggal'];
                                      } else if (data['tanggal'] == null) {
                                        tanggalPemeriksaanStr =
                                            'Tanggal tidak diinput';
                                      }

                                      final String catatanPemeriksaan =
                                          data['catatan'] ??
                                          'Tidak ada catatan.';
                                      final String namaPasienDariData =
                                          data['namaPasien'] ??
                                          'Nama Tidak Ada';

                                      return Card(
                                        color: cardColor,
                                        elevation: 2.5,
                                        shadowColor: Colors.blueGrey
                                            .withOpacity(0.15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      "Pasien: $namaPasienDariData",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 15,
                                                        color: primaryColor
                                                            .withOpacity(0.85),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      tanggalPemeriksaanStr,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        color: primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 14),
                                              Text(
                                                "Catatan Dokter:",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColorPrimary
                                                      .withOpacity(0.8),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10,
                                                    ),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: backgroundColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                child: Text(
                                                  catatanPemeriksaan.isNotEmpty
                                                      ? catatanPemeriksaan
                                                      : "Tidak ada catatan khusus dari dokter.",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: textColorSecondary,
                                                    height: 1.45,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
