import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'budidaya_screen.dart';
import 'otomasi_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Menyimpan index menu yang sedang aktif (0 = Dashboard)

  // Daftar halaman yang akan ditampilkan berdasarkan index navbar
  final List<Widget> _pages = [
    const DashboardScreen(),
    const BudidayaScreen(),
    const OtomasiScreen(),
    const ProfileScreen(),
  ];

  // Fungsi yang dipanggil saat tombol navbar ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan halaman dari list _pages sesuai dengan _selectedIndex
      body: _pages[_selectedIndex],
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // fixed agar label selalu terlihat
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF163832), // Warna saat aktif (Hijau Gelap)
        unselectedItemColor: Colors.grey[400], // Warna saat tidak aktif
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: _selectedIndex, // Menandai ikon mana yang aktif
        onTap: _onItemTapped, // Menjalankan fungsi ganti halaman
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard), // Ikon berubah saat aktif
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined),
            activeIcon: Icon(Icons.eco),
            label: 'Budidaya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_input_component_outlined),
            activeIcon: Icon(Icons.settings_input_component),
            label: 'Otomasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}