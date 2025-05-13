const express = require('express');
const router = express.Router();
const { verifyOtp, changePassword } = require('../controllers/otpController');

router.post('/verify-otp', verifyOtp);
router.post('/change-password', changePassword);
module.exports = router;
