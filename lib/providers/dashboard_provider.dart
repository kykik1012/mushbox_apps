import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/mqtt_service.dart';

class DashboardProvider with ChangeNotifier {
  final MqttService _mqttService = MqttService();

  String kelembabanTanah = "--";
  String kelembabanUdara = "--"; 
  String suhu = "--";
  String levelAir = "--";
  String kualitasUdara = "--"; // Tambahan untuk MQ-135

  String selectedChart = 'Tanah';

  List<FlSpot> chartDataTanah = [];
  List<FlSpot> chartDataUdara = [];
  List<FlSpot> chartDataSuhu = [];
  List<FlSpot> chartDataCo2 = [];
  double _timeIndex = 0;

  // --- VARIABEL STATUS PERANGKAT (Disamakan dengan skema diagram) ---
  bool isNodeSensorOnline = false; // Mewakili ESP32 (DHT11, Soil, HC-SR04, MQ-135)
  bool isPompaOnline = false;      // Mewakili Water Pump
  bool isKipasOnline = false;      // Mewakili Fan

  Timer? _sensorTimeout;

  DashboardProvider() {}

  void initMqtt() {
    _mqttService.connect(
      onMessageReceived: (data) {
        _timeIndex++; 

        // TANGKAP DATA SENSOR (Termasuk data baru dari MQ-135 & Ultrasonik)
        if (data['temp'] != null) suhu = (data['temp'] as num).toStringAsFixed(1);
        if (data['hum'] != null) kelembabanUdara = (data['hum'] as num).toStringAsFixed(1);
        if (data['soil'] != null) kelembabanTanah = (data['soil'] as num).toStringAsFixed(0);
        if (data['dist'] != null) levelAir = (data['dist'] as num).toStringAsFixed(0); // HC-SR04
        if (data['co2'] != null) kualitasUdara = (data['co2'] as num).toStringAsFixed(0); // MQ-135

       // TANGKAP DATA DAN MASUKKAN KE TITIK GRAFIK
        if (data['temp'] != null) {
          chartDataSuhu.add(FlSpot(_timeIndex, (data['temp'] as num).toDouble()));
          if (chartDataSuhu.length > 20) chartDataSuhu.removeAt(0); // Batasi 20 titik agar tidak menumpuk
        }
        
        if (data['hum'] != null) {
          chartDataUdara.add(FlSpot(_timeIndex, (data['hum'] as num).toDouble()));
          if (chartDataUdara.length > 20) chartDataUdara.removeAt(0);
        }

        if (data['soil'] != null) {
          chartDataTanah.add(FlSpot(_timeIndex, (data['soil'] as num).toDouble()));
          if (chartDataTanah.length > 20) chartDataTanah.removeAt(0);
        }

        if (data['co2'] != null) {
          chartDataCo2.add(FlSpot(_timeIndex, (data['co2'] as num).toDouble()));
          if (chartDataCo2.length > 20) chartDataCo2.removeAt(0); 
        }

        // 1. CEK STATUS AKTUATOR DARI RELAY
        // Pastikan kodingan ESP32-mu mengirim status terpisah untuk kipas dan pompa
        // 1. CEK STATUS AKTUATOR DARI RELAY
        // KITA TUKAR LOGIKANYA DI SINI KARENA HARDWARE TERBALIK
        // 1. CEK STATUS AKTUATOR DARI RELAY (KEMBALIKAN NORMAL)
        if (data['pump'] != null) isPompaOnline = data['pump'] == 'ON'; 
        if (data['fan'] != null) isKipasOnline = data['fan'] == 'ON';

        // 2. CEK STATUS ESP32 (Fitur Timeout)
        isNodeSensorOnline = true; 
        _resetSensorTimeout();

        notifyListeners(); 
      },
      onDisconnected: () {
        _setAllDevicesOffline();
        debugPrint("Provider: Koneksi MQTT Terputus!");
      }
    );
  }

  void _resetSensorTimeout() {
    _sensorTimeout?.cancel();
    
    _sensorTimeout = Timer(const Duration(seconds: 10), () {
      // Jika 10 detik ESP32 tidak mengirim data, anggap semua sistem mati
      _setAllDevicesOffline();
      debugPrint("⚠️ ESP32 Offline: Tidak ada data masuk selama 10 detik!");
    });
  }

  void _setAllDevicesOffline() {
    isNodeSensorOnline = false;
    isPompaOnline = false;
    isKipasOnline = false;
    notifyListeners();
  }

  void setChartMode(String mode) {
    selectedChart = mode;
    notifyListeners();
  }

  void manualTogglePompa(bool turnOn) {
    String msg = turnOn ? "ON" : "OFF";
    _mqttService.publishMessage("mewing/relay/pump", msg); // Pompa ke jalur pump
    isPompaOnline = turnOn;
    notifyListeners();
  }

  void manualToggleKipas(bool turnOn) {
    String msg = turnOn ? "ON" : "OFF";
    _mqttService.publishMessage("mewing/relay/fan", msg); // Kipas ke jalur fan
    isKipasOnline = turnOn;
    notifyListeners();
  }
}