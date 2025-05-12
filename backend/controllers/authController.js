const db = require('../config/firebase');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

// Step 1 - Verifikasi Data Awal
const verifyData = async (req, res) => {
  const { nik, nama, tanggalLahir } = req.body;
  try {
    const userRef = db.collection('users').doc(nik);
    const doc = await userRef.get();
    if (doc.exists) return res.status(400).json({ message: 'NIK sudah digunakan' });

    await userRef.set({
      nik, nama, tanggalLahir, createdAt: new Date(), step: 'verified'
    });

    res.status(200).json({ message: 'Verifikasi berhasil', nik });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Step 2 - Lengkapi Registrasi
const registerUser = async (req, res) => {
  const { nik, telepon, email, password } = req.body;
  try {
    const userRef = db.collection('users').doc(nik);
    const doc = await userRef.get();

    if (!doc.exists || doc.data().step !== 'verified') {
      return res.status(400).json({ message: 'NIK belum diverifikasi' });
    }

    const hash = await bcrypt.hash(password, 10);
    await userRef.update({
      telepon, email, password: hash, step: 'registered'
    });

    const token = jwt.sign({ nik }, process.env.JWT_SECRET, { expiresIn: '1d' });

    res.status(201).json({
      message: 'Registrasi berhasil',
      userId: nik,
      createdAt: new Date(),
      token: `Bearer ${token}`
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Login
const loginUser = async (req, res) => {
  const { nik, email, password } = req.body;
  try {
    const userRef = db.collection('users').doc(nik);
    const doc = await userRef.get();

    if (!doc.exists || doc.data().email !== email) {
      return res.status(401).json({ message: 'Email atau NIK salah' });
    }

    const match = await bcrypt.compare(password, doc.data().password);
    if (!match) return res.status(401).json({ message: 'Password salah' });

    const token = jwt.sign({ nik }, process.env.JWT_SECRET, { expiresIn: '1d' });

    res.status(200).json({
      message: 'Login berhasil',
      userId: nik,
      createdAt: doc.data().createdAt,
      token: `Bearer ${token}`
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Lupa Password - kirim OTP
const forgotPassword = async (req, res) => {
  const { email } = req.body;
  const users = await db.collection('users').where('email', '==', email).get();

  if (users.empty) return res.status(404).json({ message: 'Email tidak ditemukan' });

  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const userDoc = users.docs[0];
  const nik = userDoc.id;

  await db.collection('otps').doc(nik).set({
    otp,
    createdAt: Date.now(),
    email
  });

  require('../utils/sendOtp')(email, otp);

  res.status(200).json({ message: 'OTP dikirim ke email' });
};



module.exports = { verifyData, registerUser, loginUser,forgotPassword };