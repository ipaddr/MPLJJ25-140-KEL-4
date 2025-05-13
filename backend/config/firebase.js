// config/firebase.js
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// You need to set up service account credentials in your environment
// or provide the path to your service account key file
let serviceAccount;
try {
  // Try to load service account from environment variable
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  } else if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
    // Or from a file path
    serviceAccount = require(process.env.FIREBASE_SERVICE_ACCOUNT_PATH);
  } else {
    // Default fallback path
    serviceAccount = require('../serviceAccountKey.json');
  }
} catch (error) {
  console.error('Error loading Firebase service account:', error);
  process.exit(1);
}

// Initialize the app
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: process.env.FIREBASE_DATABASE_URL
});

// Export the Firestore database
const db = admin.firestore();

module.exports = db;