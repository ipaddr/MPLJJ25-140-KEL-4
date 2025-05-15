require('dotenv').config(); // Tambahkan ini di baris pertama jika belum ada
const nodemailer = require('nodemailer');

module.exports = async (email, otp) => {
  let transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER, 
      pass: process.env.EMAIL_PASS
    }
  });

  await transporter.sendMail({
    from: `"${process.env.EMAIL_SENDER_NAME}" <${process.env.EMAIL_USER}>`, 
    to: email,
    subject: 'OTP Pemulihan Kata Sandi',
    text: `Kode OTP Anda adalah: ${otp}`
  });
};
