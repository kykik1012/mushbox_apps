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

  // Fungsi Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Gagal keluar dari akun: $e');
    }
  }

  Future<void> updateAccountSecurity({
    required String currentPassword,
    String? newEmail,
    String? newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Sesi login tidak valid.');

    try {
      // 1. RE-AUTENTIKASI: Wajib dilakukan sebelum mengganti data sensitif
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. GANTI EMAIL (Jika diisi dan berbeda dari yang lama)
      if (newEmail != null && newEmail.isNotEmpty && newEmail != user.email) {
        // Catatan: Di versi Firebase terbaru, ini akan mengirimkan email verifikasi
        // ke email baru sebelum benar-benar diubah.
        await user.verifyBeforeUpdateEmail(newEmail); 
      }

      // 3. GANTI PASSWORD (Jika kolom password baru diisi)
      if (newPassword != null && newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Password saat ini salah.');
      }
      throw Exception(e.message ?? 'Gagal memperbarui keamanan akun.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}