import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up dengan email, password, dan NIK
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String nik,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      // Cek apakah NIK sudah digunakan
      QuerySnapshot nikQuery = await _firestore
          .collection('users')
          .where('nik', isEqualTo: nik)
          .get();

      if (nikQuery.docs.isNotEmpty) {
        return AuthResult.error('NIK sudah terdaftar');
      }

      // Create user dengan Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan data user ke Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'nik': nik,
        'name': name,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Update display name
      await userCredential.user!.updateDisplayName(name);

      return AuthResult.success(userCredential.user!);

    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Terjadi kesalahan: $e');
    }
  }

  // Sign in dengan email, password, dan NIK
  Future<AuthResult> signIn({
    required String email,
    required String password,
    required String nik,
  }) async {
    try {
      // Sign in dengan Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verifikasi NIK di Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return AuthResult.error('Data pengguna tidak ditemukan');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String storedNIK = userData['nik'] ?? '';

      if (storedNIK != nik) {
        await _auth.signOut();
        return AuthResult.error('NIK tidak sesuai dengan akun ini');
      }

      // Update last login
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return AuthResult.success(userCredential.user!);

    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Terjadi kesalahan: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null, message: 'Link reset password telah dikirim ke email Anda');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Terjadi kesalahan: $e');
    }
  }

  // Get user data dari Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data
  Future<bool> updateUserData(Map<String, dynamic> data) async {
    try {
      if (currentUser == null) return false;

      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(data);

      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (currentUser == null) {
        return AuthResult.error('User tidak ditemukan');
      }

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );

      await currentUser!.reauthenticateWithCredential(credential);

      // Update password
      await currentUser!.updatePassword(newPassword);

      return AuthResult.success(currentUser!, message: 'Password berhasil diubah');

    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Terjadi kesalahan: $e');
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount(String password) async {
    try {
      if (currentUser == null) {
        return AuthResult.error('User tidak ditemukan');
      }

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );

      await currentUser!.reauthenticateWithCredential(credential);

      // Delete user data dari Firestore
      await _firestore.collection('users').doc(currentUser!.uid).delete();

      // Delete user dari Firebase Auth
      await currentUser!.delete();

      return AuthResult.success(null, message: 'Akun berhasil dihapus');

    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Terjadi kesalahan: $e');
    }
  }

  // Helper method untuk mengkonversi Firebase Auth error ke pesan Indonesia
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-not-found':
        return 'Akun tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'requires-recent-login':
        return 'Silakan login ulang untuk melanjutkan';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}

// Class untuk handling result dari AuthService
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;
  final String? message;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
    this.message,
  });

  factory AuthResult.success(User? user, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}