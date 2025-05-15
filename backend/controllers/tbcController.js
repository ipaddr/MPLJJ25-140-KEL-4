// controllers/tbcController.js
const { validationResult } = require('express-validator');

const TBCScreening = {
  // Pertanyaan untuk screening TBC
  questions: [
    { id: 1, question: "Apakah Anda batuk selama 2 minggu atau lebih?" },
    { id: 2, question: "Apakah Anda batuk berdarah?" },
    { id: 3, question: "Apakah Anda mengalami penurunan berat badan secara drastis tanpa sebab yang jelas?" },
    { id: 4, question: "Apakah Anda sering berkeringat di malam hari?" },
    { id: 5, question: "Apakah Anda mengalami demam yang berlangsung lebih dari seminggu?" },
    { id: 6, question: "Apakah Anda merasa sesak napas atau nyeri dada?" },
    { id: 7, question: "Apakah Anda merasa sangat lelah sepanjang waktu?" },
    { id: 8, question: "Apakah Anda pernah kontak dekat dengan penderita TBC?" }
  ],

  // Mendapatkan pertanyaan screening
  getScreeningQuestions: (req, res) => {
    try {
      return res.status(200).json({
        success: true,
        message: 'Pertanyaan screening TBC berhasil diambil',
        data: TBCScreening.questions
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Terjadi kesalahan saat mengambil pertanyaan screening',
        error: error.message
      });
    }
  },

  // Submit hasil screening
  submitScreening: (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validasi gagal',
          errors: errors.array()
        });
      }

      const { answers } = req.body;
      
      // Validasi struktur jawaban
      if (!answers || !Array.isArray(answers)) {
        return res.status(400).json({
          success: false,
          message: 'Format jawaban tidak valid. Harap kirim array jawaban'
        });
      }

      // Hitung skor risiko berdasarkan jawaban
      let riskScore = 0;
      let answeredQuestions = 0;
      
      answers.forEach(answer => {
        if (answer.questionId && answer.answer === true) {
          riskScore++;
        }
        if (answer.questionId) {
          answeredQuestions++;
        }
      });

      // Memastikan semua pertanyaan telah dijawab
      if (answeredQuestions < TBCScreening.questions.length) {
        return res.status(400).json({
          success: false,
          message: 'Harap jawab semua pertanyaan screening'
        });
      }

      // Evaluasi hasil
      let result = {
        riskScore,
        totalQuestions: TBCScreening.questions.length,
        riskLevel: "",
        recommendation: "",
        potentialTBC: false
      };

      // Tentukan tingkat risiko dan rekomendasi
      if (riskScore >= 3) {
        result.riskLevel = "Tinggi";
        result.recommendation = "Berdasarkan gejala yang Anda alami, terdapat kemungkinan Anda menderita TBC. Segera periksakan diri ke fasilitas kesehatan terdekat untuk mendapatkan diagnosis dan penanganan yang tepat.";
        result.potentialTBC = true;
      } else if (riskScore >= 1) {
        result.riskLevel = "Sedang";
        result.recommendation = "Anda memiliki beberapa gejala yang mungkin terkait dengan TBC. Sebaiknya periksakan kesehatan Anda ke dokter untuk memastikan kondisi Anda.";
        result.potentialTBC = false;
      } else {
        result.riskLevel = "Rendah";
        result.recommendation = "Berdasarkan jawaban Anda, kemungkinan Anda menderita TBC sangat kecil. Tetap jaga kesehatan dan lakukan pemeriksaan rutin. Jika muncul gejala baru, segera konsultasikan ke dokter.";
        result.potentialTBC = false;
      }

      return res.status(200).json({
        success: true,
        message: 'Screening TBC berhasil',
        data: result
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Terjadi kesalahan saat memproses screening',
        error: error.message
      });
    }
  },

  // Mendapatkan informasi edukasi tentang TBC
  getTBCEducation: (req, res) => {
    try {
      const educationInfo = {
        whatIsTB: "Tuberkulosis (TBC) adalah penyakit menular yang disebabkan oleh bakteri Mycobacterium tuberculosis. TBC biasanya menyerang paru-paru, tetapi dapat juga menyerang bagian tubuh lainnya.",
        transmission: "TBC menyebar melalui udara ketika seseorang dengan TBC aktif batuk, bersin, atau berbicara.",
        symptoms: [
          "Batuk yang berlangsung lebih dari 2 minggu",
          "Batuk berdarah",
          "Nyeri dada",
          "Penurunan berat badan",
          "Demam",
          "Keringat malam",
          "Kelelahan"
        ],
        prevention: [
          "Vaksinasi BCG",
          "Pengobatan dini",
          "Ventilasi yang baik",
          "Menghindari kontak dekat dengan penderita TBC aktif",
          "Menggunakan masker saat diperlukan"
        ],
        treatment: "Pengobatan TBC memerlukan konsumsi antibiotik selama 6-9 bulan. Penting untuk menyelesaikan seluruh rangkaian pengobatan, meskipun gejala sudah membaik."
      };

      return res.status(200).json({
        success: true,
        message: 'Informasi edukasi TBC berhasil diambil',
        data: educationInfo
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Terjadi kesalahan saat mengambil informasi edukasi',
        error: error.message
      });
    }
  }
};

module.exports = TBCScreening;