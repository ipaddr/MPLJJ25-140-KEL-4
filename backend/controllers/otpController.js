// controllers/otpController.js
const db = require('../config/firebase');
const generateOtp = require('../utils/generateOtp');
const sendOtpEmail = require('../utils/sendOtp');
const bcrypt = require('bcrypt'); // To hash the new password
const { verifyData } = require('./authController');

// Function to send OTP
const sendOtp = async (req, res) => {
  try {
    const { email } = req.body;

    const otp = generateOtp();
    await sendOtpEmail(email, otp); // Using the renamed utility function

    await db.collection('otps').add({
      email,
      otp,
      createdAt: new Date(),
    });

    res.status(200).json({ message: 'OTP berhasil dikirim ke email' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Gagal mengirim OTP' });
  }
};

// Function to verify OTP
const verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;
    const snapshot = await db.collection('otps').where('email', '==', email).get();

    if (snapshot.empty) return res.status(404).json({ message: 'OTP tidak ditemukan' });

    const doc = snapshot.docs[0];
    const data = doc.data();

    if (data.otp !== otp) return res.status(400).json({ message: 'OTP salah' });

    const now = new Date();
    const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date(data.createdAt);

    if ((now - createdAt) / 1000 > 5 * 60) {
      return res.status(410).json({ message: 'OTP telah kedaluwarsa' });
    }

    return res.status(200).json({ message: 'OTP valid, silakan ganti password' });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Terjadi kesalahan saat verifikasi OTP' });
  }
};

// Function to change password
const changePassword = async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    // Ensure the new password is provided
    if (!newPassword) {
      return res.status(400).json({ message: 'Password baru tidak boleh kosong' });
    }

    // Hash the new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Find the user in the database and update the password
    const userRef = db.collection('users').where('email', '==', email);
    const userSnapshot = await userRef.get();

    if (userSnapshot.empty) {
      return res.status(404).json({ message: 'Pengguna tidak ditemukan' });
    }

    // Assuming there's only one document for the user
    const userDoc = userSnapshot.docs[0];
    await userDoc.ref.update({
      password: hashedPassword,
    });

    return res.status(200).json({ message: 'Password berhasil diubah' });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Terjadi kesalahan saat mengganti password' });
  }
};

module.exports = { sendOtp, verifyOtp, changePassword };
