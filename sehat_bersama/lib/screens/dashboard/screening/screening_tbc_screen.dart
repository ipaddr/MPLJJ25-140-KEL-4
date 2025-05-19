import 'package:flutter/material.dart';

class ScreeningTBCScreen extends StatefulWidget {
  const ScreeningTBCScreen({super.key});

  @override
  State<ScreeningTBCScreen> createState() => _ScreeningTBCScreenState();
}

class _ScreeningTBCScreenState extends State<ScreeningTBCScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  String? selectedGender;

  final Map<String, bool?> answers = {};

  final List<String> questions = [
    "Batuk tidak sembuh > 2 minggu?",
    "Tinggal/berinteraksi dengan penderita TBC?",
    "Pakai obat suntik tanpa anjuran dokter?",
    "Ventilasi rumah dibuka tiap hari?",
    "Tidak makan 3x sehari lengkap 4 sehat 5 sempurna?",
    "Konsumsi obat penurun imunitas (cth: kortikosteroid)?",
    "Punya riwayat penyakit serius (diabetes, HIV, kanker, ginjal)?",
    "Badan lemas tanpa sebab jelas?",
    "Keringat malam tanpa sebab jelas?",
    "Demam > 37.5°C lebih dari 2 minggu?",
    "Turun berat badan > 5 kg tanpa sebab jelas?",
    "Batuk berdarah?",
  ];

  void _submit() {
    int score = 0;
    for (var value in answers.values) {
      if (value == true) score++;
    }

    String hasil = score >= 3
        ? "Berpotensi TBC. Segera lakukan pemeriksaan di faskes terdekat."
        : "Tidak terindikasi TBC. Tetap jaga kesehatan & rutin periksa.";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(score >= 3 ? "⚠️ Screening Positif" : "✅ Screening Negatif"),
        content: Text(hasil),
        actions: [
          if (score >= 3)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/registrasi-online');
              },
              child: const Text("Registrasi Online"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Screening TBC"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Identitas", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: birthController,
                style: const TextStyle(color: Colors.black),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    birthController.text = "${picked.day}/${picked.month}/${picked.year}";
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Tanggal Lahir",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: const [
                  DropdownMenuItem(value: "Laki-laki", child: Text("Laki-laki")),
                  DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
                ],
                onChanged: (val) => setState(() => selectedGender = val),
                decoration: const InputDecoration(labelText: "Jenis Kelamin", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const Text("Pertanyaan Screening", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Pertanyaan Screening
              ...questions.map((q) {
                answers.putIfAbsent(q, () => null);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            value: true,
                            groupValue: answers[q],
                            onChanged: (val) => setState(() => answers[q] = val),
                            title: const Text("Ya"),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            value: false,
                            groupValue: answers[q],
                            onChanged: (val) => setState(() => answers[q] = val),
                            title: const Text("Tidak"),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Submit"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
