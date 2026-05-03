import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<String> uploadProfileImage(XFile imageFile) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Sesi login tidak valid');

    try {
      // 1. Ubah gambar menjadi format bytes (Agar aman untuk Web dan Mobile)
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.name.split('.').last;
      
      // 2. Buat nama file unik: "uid_pengguna/profile_waktu.jpg"
      final fileName = '${user.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // 3. Upload ke Supabase Storage (Ganti 'profile_pics' dengan nama bucket-mu)
      await _supabase.storage.from('profile').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true), // Timpa file lama
      );

      // 4. Dapatkan URL Publik dari gambar yang baru diupload
      final imageUrl = _supabase.storage.from('profile_pics').getPublicUrl(fileName);

      // 5. Simpan URL tersebut ke dalam tabel profiles
      await _supabase.from('profiles').upsert({
        'id': user.uid,
        'foto_url': imageUrl,
      });

      return imageUrl; // Kembalikan URL agar UI bisa langsung update
    } catch (e) {
      throw Exception('Gagal mengunggah foto: $e');
    }
  }
}