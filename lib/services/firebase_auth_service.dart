import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      // Menangkap error secara umum (catch (e)) jauh lebih aman di Web
      if (e is FirebaseAuthException) {
        throw Exception(e.message ?? 'Terjadi kesalahan saat login.');
      }
      // Jika bukan FirebaseAuthException, lempar pesan aslinya
      throw Exception('Login gagal: $e');
    }
  }

  // Fungsi Lupa Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw Exception(e.message ?? 'Gagal mengirim email reset password.');
      }
      throw Exception('Gagal mengirim email: $e');
    }
  }
}