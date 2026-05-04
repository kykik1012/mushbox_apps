import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class DashboardProvider with ChangeNotifier {
  final MqttService _mqttService = MqttService();

  // 1. PASTIKAN SEMUA VARIABEL INI BERTIPE STRING
  String kelembabanTanah = "--";
  String kelembabanUdara = "--"; 
  String suhu = "--";
  String levelAir = "--";

  String selectedChart = 'Tanah';

  bool isSensorAOnline = true;
  bool isPompaOnline = false;
  bool isSensorBOnline = false;
  bool isKipasOnline = true;

  DashboardProvider() {
    // Kosongkan saja constructor-nya karena akan dipanggil dari main_screen
  }

  // 2. NAMA FUNGSI TANPA GARIS BAWAH AGAR BISA DIPANGGIL FILE LAIN
  void initMqtt() {
    _mqttService.connect(
     onMessageReceived: (data) {
        // UBAH 'suhu' MENJADI 'temp'
        if (data['temp'] != null) {
          suhu = (data['temp'] as num).toStringAsFixed(1); 
        }
        
        // UBAH 'kelembapan' MENJADI 'hum'
        if (data['hum'] != null) {
          kelembabanUdara = (data['hum'] as num).toStringAsFixed(1);
        }
        
        if (data['relay_status'] != null) {
          isPompaOnline = data['relay_status'] == "Online";
        }
        notifyListeners(); 
      },
      onDisconnected: () {
        isPompaOnline = false;
        notifyListeners();
        debugPrint("Provider: Koneksi MQTT Terputus!");
      }
    );
  }

  void setChartMode(String mode) {
    selectedChart = mode;
    notifyListeners();
  }
}
