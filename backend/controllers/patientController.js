// controllers/patientController.js
const admin = require('firebase-admin');

// Register patient information
const registerPatient = async (req, res) => {
  try {
    // Get user info from auth middleware
    const { nik } = req.user;
    
    // Get patient registration details from request body
    const { namaLengkap, alamatEmail, nomorTelepon, tanggalPemeriksaan, jenisKelamin } = req.body;
    
    // Validate required fields
    if (!namaLengkap || !alamatEmail || !nomorTelepon || !tanggalPemeriksaan || !jenisKelamin) {
      return res.status(400).json({ message: 'Semua field harus diisi' });
    }
    
    // Create patient record in database
    const db = admin.firestore();
    const patientRef = db.collection('patients').doc();
    
    const patientData = {
      userId: nik,
      namaLengkap,
      alamatEmail,
      nomorTelepon,
      tanggalPemeriksaan,
      jenisKelamin,
      status: 'terdaftar',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await patientRef.set(patientData);
    
    // Generate registration number (simple format: date + random)
    const registrationDate = new Date().toISOString().slice(0,10).replace(/-/g,'');
    const randomDigits = Math.floor(1000 + Math.random() * 9000);
    const nomorRegistrasi = `REG-${registrationDate}-${randomDigits}`;
    
    // Update patient record with registration number
    await patientRef.update({
      nomorRegistrasi
    });
    
    res.status(201).json({ 
      message: 'Registrasi pasien berhasil',
      nomorRegistrasi,
      data: {
        namaLengkap,
        alamatEmail,
        nomorTelepon,
        tanggalPemeriksaan,
        jenisKelamin
      }
    });
    
  } catch (err) {
    console.error('Error registering patient:', err);
    res.status(500).json({ message: 'Terjadi kesalahan saat mendaftarkan pasien' });
  }
};

// Get all patient registrations for the logged in user
const getPatientRegistrations = async (req, res) => {
  try {
    const { nik } = req.user;
    
    // Use admin directly instead of imported db
    const db = admin.firestore();
    const patientsRef = db.collection('patients');
    
    // Use a simple query first without the orderBy
    const patientsSnapshot = await patientsRef.where('userId', '==', nik).get();
    
    if (patientsSnapshot.empty) {
      return res.status(200).json({ 
        message: 'Belum ada pendaftaran pasien',
        data: [] 
      });
    }
    
    const patients = [];
    patientsSnapshot.forEach(doc => {
      const data = doc.data();
      patients.push({
        id: doc.id,
        nomorRegistrasi: data.nomorRegistrasi || '',
        namaLengkap: data.namaLengkap,
        tanggalPemeriksaan: data.tanggalPemeriksaan,
        status: data.status,
        jenisKelamin: data.jenisKelamin,
        createdAt: data.createdAt
      });
    });
    
    // Sort in memory by createdAt timestamp
    patients.sort((a, b) => {
      const timeA = a.createdAt ? 
        (a.createdAt._seconds ? a.createdAt._seconds : a.createdAt.getTime() / 1000) : 0;
      const timeB = b.createdAt ? 
        (b.createdAt._seconds ? b.createdAt._seconds : b.createdAt.getTime() / 1000) : 0;
      
      return timeB - timeA; // Descending order
    });
    
    // Remove createdAt from response
    const formattedPatients = patients.map(({ createdAt, ...rest }) => rest);
    
    res.status(200).json({
      message: 'Data registrasi pasien berhasil diambil',
      data: formattedPatients
    });
    
  } catch (err) {
    console.error('Error getting patient registrations:', err);
    res.status(500).json({ message: 'Terjadi kesalahan saat mengambil data pendaftaran' });
  }
};

// Get patient registration details
const getPatientDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const { nik } = req.user;
    
    const db = admin.firestore();
    const patientDoc = await db.collection('patients').doc(id).get();
    
    if (!patientDoc.exists) {
      return res.status(404).json({ message: 'Data pasien tidak ditemukan' });
    }
    
    const patientData = patientDoc.data();
    
    // Verify that this patient belongs to logged in user
    if (patientData.userId !== nik) {
      return res.status(403).json({ message: 'Anda tidak memiliki akses ke data ini' });
    }
    
    res.status(200).json({
      message: 'Data pasien berhasil diambil',
      data: patientData
    });
    
  } catch (err) {
    console.error('Error getting patient detail:', err);
    res.status(500).json({ message: 'Terjadi kesalahan saat mengambil detail pasien' });
  }
};

module.exports = { registerPatient, getPatientRegistrations, getPatientDetail };