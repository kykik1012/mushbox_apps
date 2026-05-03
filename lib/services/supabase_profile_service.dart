import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupabaseProfileService {
  final _supabase = Supabase.instance.client;
  final _firebaseAuth = FirebaseAuth.instance;

  // 1. Mengambil data profile dari Supabase
  Future<Map<String, dynamic>?> getProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null; // Jika belum login Firebase

    try {
      // Query ke PostgreSQL Supabase
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.uid)
          .maybeSingle(); // Ambil 1 baris data jika ada
          
      return response;
    } catch (e) {
      throw Exception('Gagal mengambil data profil: $e');
    }
  }

  // 2. Menyimpan atau Memperbarui data profile (Upsert)
  Future<void> saveProfile({
    required String namaLengkap,
    required String alamat,
    required String noTelp,
    String? fotoUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Sesi login tidak valid');

    try {
      // Fitur Upsert (Update or Insert) sangat cocok di sini
      await _supabase.from('profiles').upsert({
        'id': user.uid, // UID Firebase menjadi kunci utamanya
        'nama_lengkap': namaLengkap,
        'alamat': alamat,
        'no_telp': noTelp,
        if (fotoUrl != null) 'foto_url': fotoUrl,
      });
    } catch (e) {
      throw Exception('Gagal menyimpan profil: $e');
    }
  }
}