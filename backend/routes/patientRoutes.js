const express = require('express');
const router = express.Router();
const { registerPatient, getPatientRegistrations, getPatientDetail } = require('../controllers/patientController');
const authMiddleware = require('../middlewares/authMiddleware');

// Apply auth middleware to all routes - ensures user is logged in
router.use(authMiddleware);

// Patient registration routes
router.post('/register', registerPatient);
router.get('/registrations', getPatientRegistrations);
router.get('/detail/:id', getPatientDetail);

module.exports = router;