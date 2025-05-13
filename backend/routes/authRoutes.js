const express = require('express');
const router = express.Router();
const { verifyData, registerUser, loginUser, forgotPassword } = require('../controllers/authController');

router.post('/verify', verifyData);
router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/forgot-password', forgotPassword);

module.exports = router;
