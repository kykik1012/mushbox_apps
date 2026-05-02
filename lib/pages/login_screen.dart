import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

// 1. Ubah menjadi StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 2. Buat Controller untuk membaca inputan text box
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 3. Buat variabel untuk menyimpan status tombol (aktif/tidak)
  bool isButtonActive = false;

  @override
  void initState() {
    super.initState();
    // 4. Tambahkan pendengar (listener) setiap kali user mengetik
    _emailController.addListener(_checkInput);
    _passwordController.addListener(_checkInput);
  }

  // Fungsi untuk mengecek apakah kedua text box sudah terisi
  void _checkInput() {
    setState(() {
      // Tombol aktif JIKA email tidak kosong DAN password tidak kosong
      isButtonActive = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    // Jangan lupa hapus controller saat halaman ditutup agar tidak bocor memori
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
              
              // TextField Email
              TextFormField(
                controller: _emailController, // Hubungkan controller di sini
                decoration: const InputDecoration(
                  labelText: 'Email',
                  suffixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),
              
              // TextField Password
              TextFormField(
                controller: _passwordController, // Hubungkan controller di sini
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 40),
              
              // Tombol Masuk
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Warna saat aktif (Hijau Gelap sesuai gambarmu)
                  backgroundColor: const Color(0xFF163832), 
                  // Warna saat tidak aktif (Abu-abu)
                  disabledBackgroundColor: Colors.grey[300], 
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
                // 5. Logika Tombol: Jika aktif, jalankan fungsi navigasi. Jika tidak, beri nilai null (otomatis disable)
                onPressed: isButtonActive 
                    ? () {
                        // Navigasi ke Dashboard
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        );
                      }
                    : null, // null membuat tombol menjadi abu-abu dan tidak bisa diklik
                child: Text(
                  'Masuk', 
                  style: TextStyle(
                    // Jika aktif warnanya putih/terang, jika tidak aktif warnanya gelap
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