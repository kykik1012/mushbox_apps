import 'package:flutter/material.dart';
import '../services/mqtt_service.dart'; // Import service MQTT yang sudah kita buat

class DashboardProvider extends ChangeNotifier {
  // 1. Instansiasi MqttService
  final MqttService _mqttService = MqttService();

  // 2. Data Sensor (Nilai awal sebelum ada data dari IoT)
  String kelembabanTanah = "72";
  String kelembabanUdara = "--"; // Pakai strip agar tahu kalau data belum masuk
  String suhu = "--";
  String levelAir = "65";

  // 3. State untuk Tab Grafik
  String selectedChart = 'Tanah';

  // 4. Status Perangkat IoT
  bool isSensorAOnline = true;
  bool isPompaOnline = false; // Kita buat default false dulu
  bool isSensorBOnline = false;
  bool isKipasOnline = true;

  // 5. Constructor: Otomatis dijalankan saat Provider pertama kali dipanggil
  DashboardProvider() {
    _initMqtt();
  }

  // Fungsi untuk menyambungkan MQTT dan mendengarkan data
  void _initMqtt() {
    // Memanggil fungsi connect dari mqtt_service.dart
    _mqttService.connect((data) {
      // 'data' ini berisi JSON dari ESP32: {"suhu": 27.0, "kelembapan": 85.0, "relay_status": "Online"}
      
      // Update Suhu
      if (data['suhu'] != null) {
        // Asumsikan data berupa angka desimal (double), kita ubah ke String dengan 1 angka di belakang koma
        suhu = (data['suhu'] as num).toStringAsFixed(1); 
      }
      
      // Update Kelembapan Udara
      if (data['kelembapan'] != null) {
        kelembabanUdara = (data['kelembapan'] as num).toStringAsFixed(1);
      }

      // Update Status Relay (Misal kita hubungkan ke status Pompa Utama)
      if (data['relay_status'] != null) {
        isPompaOnline = data['relay_status'] == "Online";
      }

      // TERIAK KE UI AGAR MENGGANTI ANGKA DI LAYAR!
      notifyListeners(); 
    });
  }

  // Fungsi untuk mengubah tab grafik (Tetap dipertahankan)
  void setChartMode(String mode) {
    selectedChart = mode;
    notifyListeners();
  }
}