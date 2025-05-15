const { validationResult } = require('express-validator');
const db = require('../config/firebase');

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
  submitScreening: async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validasi gagal',
          errors: errors.array()
        });
      }

      const { fullName, birthDate, gender, answers } = req.body;

      // Validasi data pengguna
      if (!fullName || !birthDate || !gender) {
        return res.status(400).json({
          success: false,
          message: 'Harap lengkapi data: nama lengkap, tanggal lahir, dan jenis kelamin.'
        });
      }

      if (!answers || !Array.isArray(answers)) {
        return res.status(400).json({
          success: false,
          message: 'Format jawaban tidak valid. Harap kirim array jawaban'
        });
      }

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

      if (answeredQuestions < TBCScreening.questions.length) {
        return res.status(400).json({
          success: false,
          message: 'Harap jawab semua pertanyaan screening'
        });
      }

      let result = {
        user: {
          fullName,
          birthDate,
          gender
        },
        riskScore,
        totalQuestions: TBCScreening.questions.length,
        riskLevel: "",
        recommendation: "",
        potentialTBC: false,
        createdAt: new Date()
      };

      if (riskScore >= 3) {
        result.riskLevel = "Tinggi";
        result.recommendation = "Berdasarkan gejala yang Anda alami, terdapat kemungkinan Anda menderita TBC. Segera periksakan diri ke fasilitas kesehatan terdekat.";
        result.potentialTBC = true;
      } else if (riskScore >= 1) {
        result.riskLevel = "Sedang";
        result.recommendation = "Anda memiliki beberapa gejala yang mungkin terkait TBC. Disarankan memeriksakan diri ke dokter.";
      } else {
        result.riskLevel = "Rendah";
        result.recommendation = "Kemungkinan Anda menderita TBC sangat kecil. Tetap jaga kesehatan dan lakukan pemeriksaan rutin.";
      }

      await db.collection('screeningResults').add(result);

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

  // Mendapatkan riwayat screening berdasarkan fullName
  getScreeningHistory: async (req, res) => {
    try {
      const { fullName } = req.query;

      if (!fullName) {
        return res.status(400).json({
          success: false,
          message: 'Parameter fullName diperlukan'
        });
      }

      const snapshot = await db.collection('screeningResults')
        .where('user.fullName', '==', fullName)
        .orderBy('createdAt', 'desc')
        .get();

      if (snapshot.empty) {
        return res.status(404).json({
          success: false,
          message: `Tidak ada riwayat screening ditemukan untuk ${fullName}`
        });
      }

      const results = [];
      snapshot.forEach(doc => {
        results.push({ id: doc.id, ...doc.data() });
      });

      return res.status(200).json({
        success: true,
        message: `Riwayat screening untuk ${fullName} berhasil diambil`,
        data: results
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Terjadi kesalahan saat mengambil riwayat screening',
        error: error.message
      });
    }
  },

  // Mendapatkan informasi edukasi tentang TBC
  getTBCEducation: (req, res) => {
    try {
      const educationInfo = {
        whatIsTB: "Tuberkulosis (TBC) adalah penyakit menular yang disebabkan oleh bakteri Mycobacterium tuberculosis.",
        transmission: "TBC menyebar melalui udara saat penderita TBC aktif batuk, bersin, atau berbicara.",
        symptoms: [
          "Batuk lebih dari 2 minggu",
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
          "Hindari kontak dekat dengan penderita TBC",
          "Gunakan masker bila perlu"
        ],
        treatment: "Pengobatan TBC memerlukan konsumsi antibiotik selama 6-9 bulan. Penting untuk menyelesaikan seluruh pengobatan."
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
