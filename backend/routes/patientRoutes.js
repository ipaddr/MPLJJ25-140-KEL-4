const express = require('express');
const router = express.Router();
const { registerPatient, getPatientRegistrations, getPatientDetail } = require('../controllers/patientController');
const authMiddleware = require('../middlewares/authMiddleware');

// Terapkan middleware autentikasi ke semua rute - pastikan pengguna sudah login
router.use(authMiddleware);

// Patient registrasi routes
router.post('/register', registerPatient);
router.get('/registrations', getPatientRegistrations);
router.get('/detail/:id', getPatientDetail);

module.exports = router;