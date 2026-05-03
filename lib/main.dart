import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import Firebase Core
import 'firebase_options.dart'; // 2. Import pengaturan Firebase
import 'pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/dashboard_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async { 
  // 4. Wajib dipanggil sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 5. Inisialisasi Firebase (Ini yang mencegah error layar merah di Web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://qkenpvuylxxholqdgtet.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFrZW5wdnV5bHh4aG9scWRndGV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3MzIyMzIsImV4cCI6MjA5MjMwODIzMn0.-pLBou8PvmgQs4R8FBNPNCARtA0XRynIxwz-WxeZbtE',           
  );

 runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        // Nanti kalau ada AuthProvider, bisa ditambah di sini
      ],
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(), 
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Tambahkan tiga baris di bawah ini agar integrasi preview berjalan lancar
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

