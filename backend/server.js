require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const otpRoutes = require('./routes/otpRoutes');
const patientRoutes = require('./routes/patientRoutes'); // Import patient routes
const tbcRoutes = require('./routes/tbcRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);      // semua endpoint auth, misal: /api/auth/register
app.use('/api/otp', otpRoutes);        // semua endpoint otp, misal: /api/otp/send-otp
app.use('/api/patient', patientRoutes); // semua endpoint patient, misal: /api/patient/register
app.use('/api/tbc', tbcRoutes);        // aktifkan route TBC: /api/tbc/screening, /api/tbc/education

// Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
