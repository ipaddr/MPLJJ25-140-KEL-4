import 'package:flutter/material.dart';

class CetakAntreanScreen extends StatelessWidget {
  const CetakAntreanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Logo + Title
          Column(
            children: [
              Image.asset('assets/images/logo.png', height: 70),
              const SizedBox(height: 16),
              const Text(
                "RS Sehat Bersama",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                "No. Rujukan: 0020TB00542314456025466884423",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              const Text("dr. Zul, Sp.P", style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),

          // Info Row
          Column(
            children: const [
              _InfoRow(icon: Icons.local_hospital, label: "Poliklinik", value: "TB-DOTS"),
              SizedBox(height: 10),
              _InfoRow(icon: Icons.calendar_today, label: "Tanggal Rujukan", value: "29-Apr-2025"),
              SizedBox(height: 10),
              _InfoRow(icon: Icons.confirmation_number, label: "Kode Booking", value: "2025042900241136"),
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
          const Center(
            child: Text(
              "TB00002-003",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StatBox(
          icon: Icons.groups,
          label: "Sisa Antrean",
          value: "4",
              ),
              _StatBox(
          icon: Icons.person,
          label: "Peserta Dilayani",
          value: "3",
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Center(
            child: Column(
              children: [
          Text("Estimasi Dilayani", style: TextStyle(fontSize: 14)),
          SizedBox(height: 4),
          Text(
            "29-04-2025 15:13",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Check-in Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
          Navigator.pushNamed(context, '/checkin-berhasil');
              },
              style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Check-In"),
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
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBox({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);
    return Column(
      children: [
        Icon(icon, size: 24, color: primaryColor),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
