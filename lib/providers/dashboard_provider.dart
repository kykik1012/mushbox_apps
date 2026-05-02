import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  // 1. Data Sensor (Nanti ini akan diupdate dari Firebase/MQTT IoT)
  String kelembabanTanah = "72";
  String kelembabanUdara = "80";
  String suhu = "25";
  String levelAir = "65";

  // 2. State untuk Tab Grafik
  String selectedChart = 'Tanah'; // Default grafik yang aktif

  // 3. Status Perangkat IoT
  bool isSensorAOnline = true;
  bool isPompaOnline = true;
  bool isSensorBOnline = false;
  bool isKipasOnline = true;

  // Fungsi untuk mengubah tab grafik
  void setChartMode(String mode) {
    selectedChart = mode;
    notifyListeners();
  }

  // Contoh fungsi yang akan dipanggil saat data IoT masuk
  void updateSensorData({
    String? tanah, String? udara, String? suhuBaru, String? air
  }) {
    if (tanah != null) kelembabanTanah = tanah;
    if (udara != null) kelembabanUdara = udara;
    if (suhuBaru != null) suhu = suhuBaru;
    if (air != null) levelAir = air;
    notifyListeners(); // Teriak ke UI untuk update!
  }
}