import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/dashboard_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/riwayat_provider.dart';
import 'providers/otomasi_provider.dart';
import 'services/notification_service.dart';

void main() async { 
  // Wajib dipanggil sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://qkenpvuylxxholqdgtet.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFrZW5wdnV5bHh4aG9scWRndGV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3MzIyMzIsImV4cCI6MjA5MjMwODIzMn0.-pLBou8PvmgQs4R8FBNPNCARtA0XRynIxwz-WxeZbtE',           
  );
  
  // Inisialisasi Notifikasi
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => RiwayatProvider()),
        ChangeNotifierProvider(create: (_) => OtomasiProvider()),
      ],
      // DevicePreview Dihapus, langsung panggil MyApp()
      child: const MyApp(), 
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" merah di pojok kanan atas
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}