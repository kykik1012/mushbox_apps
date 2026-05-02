import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../services/firebase_auth_service.dart'; // Import service yang baru dibuat
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Instansiasi service
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool isButtonActive = false;
  bool isLoading = false; // Tambahkan state untuk loading

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkInput);
    _passwordController.addListener(_checkInput);
  }

  void _checkInput() {
    setState(() {
      isButtonActive = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  // Fungsi untuk mengeksekusi login
  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true; // Munculkan loading
    });

    try {
      // Menggunakan Firebase Service yang baru kita buat
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result != null && mounted) {
        // Jika sukses, pindah ke Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()), // <-- Ubah di sini
        );
      }
    } catch (e) {
      // Jika gagal, tampilkan Snackbar peringatan
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Matikan loading
        });
      }
    }
  }

  // Fungsi untuk Lupa Password
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi alamat email Anda terlebih dahulu di kolom Email.')),
      );
      return;
    }

    try {
      await _authService.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email reset password telah dikirim! Coba cek kotak masuk atau spam Anda.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Image(
                  image: AssetImage('assets/images/Text_Mushbox_full.png'),
                  height: 100,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Selamat Datang Kembali',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk untuk memantau dan mengontrol kondisi budidaya jamur Anda secara real-time.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress, // Keyboard khusus email
                decoration: const InputDecoration(
                  labelText: 'Email',
                  suffixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              
              // Tambahan: Tombol Lupa Password di sebelah kanan
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text('Lupa Password?'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF163832), 
                  disabledBackgroundColor: Colors.grey[300], 
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
                // Logika diperbarui: Jika sedang loading, nonaktifkan tombol
                onPressed: (isButtonActive && !isLoading) ? _handleLogin : null,
                child: isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Text(
                      'Masuk', 
                      style: TextStyle(
                        color: isButtonActive ? const Color(0xFFDAF1DE) : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}