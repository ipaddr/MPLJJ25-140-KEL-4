function generateOtp(length = 6) {
  let otp = '';
  for (let i = 0; i < length; i++) {
    otp += Math.floor(Math.random() * 10); // angka 0-9
  }
  return otp;
}

module.exports = generateOtp;
