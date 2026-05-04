import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class DashboardProvider with ChangeNotifier {
  final MqttService _mqttService = MqttService();

  // --- DATA SENSOR MQTT ---
  double suhu = 0.0;
  double kelembabanUdara = 0.0; // Sudah diubah pakai 'b' menyesuaikan UI
  double kelembabanTanah = 0.0; // Sudah diubah pakai 'b' menyesuaikan UI
  int levelAir = 0;
  bool isConnected = false;

  // --- DATA STATUS DEVICE (Untuk mengatasi error isPompaOnline, isKipasOnline, dll) ---
  bool isSensorAOnline = false;
  bool isSensorBOnline = false;
  bool isPompaOnline = false;
  bool isKipasOnline = false;

  // --- DATA CHART (Untuk mengatasi error selectedChart & setChartMode) ---
  // Asumsi tipe data chart mode adalah String ('Harian', 'Mingguan', dll)
  // Ubah tipe data jika ternyata di UI menggunakan int (index)
  String selectedChart = 'Harian';

  void setChartMode(String mode) {
    selectedChart = mode;
    notifyListeners();
  }

  // --- FUNGSI MQTT ---
  void initMqtt() {
    _mqttService.connect(
      onMessageReceived: (data) {
        // Sesuaikan nama key (yang di dalam kutip) dengan JSON dari C++
        suhu =
            double.tryParse(data['temp'].toString()) ??
            0.0; // Ubah 'suhu' jadi 'temp'
        kelembabanUdara =
            double.tryParse(data['hum'].toString()) ??
            0.0; // Ubah 'h_udara' jadi 'hum'

        // Catatan: Karena ESP kamu saat ini belum mengirim data tanah dan air,
        // maka 2 bagian di bawah ini sementara akan tetap bernilai 0.0
        kelembabanTanah = double.tryParse(data['h_tanah'].toString()) ?? 0.0;
        levelAir = int.tryParse(data['air'].toString()) ?? 0;

        isConnected = true;
        isSensorAOnline = true;
        isSensorBOnline = true;

        notifyListeners(); // Menyuruh UI update angka
      },
      onDisconnected: () {
        isConnected = false;
        isSensorAOnline = false;
        isSensorBOnline = false;
        notifyListeners();
      },
    );
  }
}
