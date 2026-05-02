import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pindah ke halaman Login setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFD4EDDA), // Warna hijau muda (sesuaikan hex-nya)
      body: Center(
        // Nanti ganti icon ini dengan Image.asset logo MushBox aslimu
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/icon_mushbox.png'),
              width: 100, // Sesuaikan ukuran logonya
              height: 100,
            ),
            SizedBox(height: 16),
            Image(
              image: AssetImage('assets/images/text.png'),
              height: 25,
            ),
            // Text(
            //   'MushBox',
            //   style: TextStyle(
            //     fontSize: 28,
            //     fontWeight: FontWeight.bold,
            //     color: Color(0xFF1B4332),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}