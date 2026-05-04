import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/supabase_profile_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart'; // Untuk navigasi saat logout
import '../widgets/profile_menu_item.dart';
import 'package:image_picker/image_picker.dart';
import 'keamanan_akun_screen.dart'; // Import layar keamanan akun

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseProfileService _profileService = SupabaseProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  Map<String, dynamic>? _profileData;
  String? _userEmail;

  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Mengambil data dari Firebase (Email) dan Supabase (Nama, No Telp, Alamat)
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _userEmail = user.email;
        final data = await _profileService.getProfile();
        setState(() {
          _profileData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changeProfilePhoto() async {
    try {
      // Buka galeri, kompres kualitas jadi 70% agar upload cepat
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return; // Dibatalkan pengguna

      setState(() => _isUploadingPhoto = true); // Munculkan loading

      // Upload ke Supabase menggunakan service
      final newUrl = await _profileService.uploadProfileImage(image);

      setState(() {
        _profileData ??= {}; // Jika _profileData null, buat map kosong
        _profileData!['foto_url'] = newUrl; // Update url fotonya
        _isUploadingPhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto berhasil diperbarui!')));
      }
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // Fungsi untuk memunculkan Form Edit (Bottom Sheet)
  void _showEditForm() {
    // Siapkan controller dan isi dengan data yang ada (jika sudah pernah diisi)
    final namaController = TextEditingController(text: _profileData?['nama_lengkap'] ?? '');
    final phoneController = TextEditingController(text: _profileData?['no_telp'] ?? '');
    final alamatController = TextEditingController(text: _profileData?['alamat'] ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar form bisa menyesuaikan keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder( // StatefulBuilder agar bisa update state tombol loading di dalam modal
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Hindari tertutup keyboard
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Edit Profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Nomor Telepon', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: alamatController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark1,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isSaving ? null : () async {
                      setModalState(() => isSaving = true);
                      try {
                        // Simpan ke Supabase
                        await _profileService.saveProfile(
                          namaLengkap: namaController.text.trim(),
                          noTelp: phoneController.text.trim(),
                          alamat: alamatController.text.trim(),
                        );
                        if (mounted) {
                          Navigator.pop(context); // Tutup modal
                          _loadProfileData(); // Refresh UI
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        setModalState(() => isSaving = false);
                      }
                    },
                    child: isSaving 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                        : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // Fungsi Logout
  Future<void> _handleLogout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Hapus semua riwayat halaman agar tidak bisa di-back
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Ambil data untuk ditampilkan (gunakan default jika kosong)
    final nama = _profileData?['nama_lengkap'] ?? 'Belum ada nama';
    final noTelp = _profileData?['no_telp'] ?? 'Belum ada nomor telepon';
    final email = _userEmail ?? 'Tidak ada email';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU PROFIL (Warna Hijau Gelap)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.dark1,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Ikon Edit di Kanan Atas
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      onPressed: _showEditForm, // Panggil modal form
                    ),
                  ),
                  // Konten Profil
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isUploadingPhoto ? null : _changeProfilePhoto,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                // Tampilkan foto jika ada URL-nya
                                backgroundImage: _profileData?['foto_url'] != null
                                    ? NetworkImage(_profileData!['foto_url'])
                                    : null,
                                // Tampilkan ikon orang JIKA URL-nya masih kosong
                                child: _profileData?['foto_url'] == null
                                    ? const Icon(Icons.person, size: 60, color: AppColors.dark1)
                                    : null,
                              ),
                              
                              // Indikator loading saat upload
                              if (_isUploadingPhoto)
                                const CircularProgressIndicator(color: AppColors.dark1),
                                
                              // Ikon kamera kecil di pojok foto
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 16, color: AppColors.dark1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          nama,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(email, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(noTelp, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Akun & Aplikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // MENU LIST
            ProfileMenuItem(
              icon: Icons.shield_outlined, 
              title: 'Keamanan Akun', 
              subtitle: 'Password & Akun',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KeamananAkunScreen()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.notifications_outlined, 
              title: 'Pengaturan Notifikasi', 
              subtitle: 'Suara & Getar pesanan masuk',
              onTap: () {},
            ),
            
            
            const SizedBox(height: 8),
            
            // TOMBOL LOGOUT
            Card(
              elevation: 0,
              color: Colors.red[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.withValues(alpha: 0.2)), 
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text('Sampai jumpa lagi!', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                onTap: _handleLogout, // Panggil fungsi logout
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk membuat Menu List agar kode lebih bersih
  
}