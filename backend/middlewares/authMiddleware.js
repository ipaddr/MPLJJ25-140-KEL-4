// middlewares/authMiddleware.js
const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');

/**
 * Authentication middleware for patient registration system
 * Validates JWT token and attaches user information to request object
 */
const authMiddleware = async (req, res, next) => {
  try {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Akses ditolak. Token tidak ditemukan' });
    }
    
    const token = authHeader.split(' ')[1];
    
    // Verify JWT token
    try {
      // Get JWT secret from environment variable
      const JWT_SECRET = process.env.JWT_SECRET;
      
      if (!JWT_SECRET) {
        throw new Error('JWT Secret not configured');
      }
      
      // Verify token
      const decoded = jwt.verify(token, JWT_SECRET);
      
      // Get user NIK from decoded token
      const { nik } = decoded;
      
      if (!nik) {
        return res.status(401).json({ message: 'Token tidak valid' });
      }
      
      // Check if user exists in database
      const userDoc = await admin.firestore().collection('users').doc(nik).get();
      
      if (!userDoc.exists) {
        return res.status(401).json({ message: 'Pengguna tidak ditemukan' });
      }
      
      // Attach user data to request object
      req.user = {
        nik,
        ...userDoc.data()
      };
      
      // Continue to next middleware/route handler
      next();
      
    } catch (err) {
      console.error('Token verification error:', err);
      
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ message: 'Token telah kedaluwarsa' });
      }
      
      return res.status(401).json({ message: 'Token tidak valid' });
    }
    
  } catch (err) {
    console.error('Auth middleware error:', err);
    res.status(500).json({ message: 'Terjadi kesalahan pada autentikasi' });
  }
};

module.exports = authMiddleware;