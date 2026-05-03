import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../theme/app_colors.dart';

class KeamananAkunScreen extends StatefulWidget {
  const KeamananAkunScreen({super.key});

  @override
  State<KeamananAkunScreen> createState() => _KeamananAkunScreenState();
}

class _KeamananAkunScreenState extends State<KeamananAkunScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  late TextEditingController _emailController;
  final TextEditingController _newPasswordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi kolom email otomatis dengan email saat ini
    _emailController = TextEditingController(text: currentUser?.email ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk memunculkan Dialog minta password lama
  Future<void> _showReAuthDialog() async {
    final emailInput = _emailController.text.trim();
    final newPasswordInput = _newPasswordController.text.trim();

    // Cegah jika user tidak mengubah apa-apa
    if (emailInput == currentUser?.email && newPasswordInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada perubahan yang perlu disimpan.')),
      );
      return;
    }

    final currentPasswordController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verifikasi Keamanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Untuk menyimpan perubahan, masukkan password Anda saat ini.'),
              const SizedBox(height: 16),
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Saat Ini',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dark1),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                _saveChanges(currentPasswordController.text.trim()); // Jalankan proses simpan
              },
              child: const Text('Verifikasi', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menyimpan perubahan ke Firebase
  Future<void> _saveChanges(String currentPassword) async {
    if (currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password saat ini harus diisi!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.updateAccountSecurity(
        currentPassword: currentPassword,
        newEmail: _emailController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keamanan akun berhasil diperbarui! Jika Anda mengganti email, silakan cek kotak masuk email baru Anda untuk verifikasi.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context); // Kembali ke halaman profil
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Keamanan Akun', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Perbarui Informasi Akun', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.edit_outlined, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Atur ulang email dan password akun Anda', style: TextStyle(color: Colors.black87)),
            
            const SizedBox(height: 40),
            
            // TextField Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email Anda',
              ),
            ),
            
            const SizedBox(height: 32),
            
            // TextField Password Baru
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password Baru (Kosongkan jika tidak diganti)',
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Tombol Simpan
            SizedBox(
              width: double.infinity, // Agar tombol memenuhi lebar layar
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark1,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  )
                ),
                onPressed: _isLoading ? null : _showReAuthDialog,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}