import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/mqtt_service.dart';
import '../services/notification_service.dart'; // 1. TAMBAHAN IMPORT NOTIFIKASI

class DashboardProvider with ChangeNotifier {
  final MqttService _mqttService = MqttService();

  String kelembabanTanah = "--";
  String kelembabanUdara = "--"; 
  String suhu = "--";
  String levelAir = "--";
  String kualitasUdara = "--"; 

  String selectedChart = 'Tanah';
  String _statusAirTerakhir = "Aman";

  List<FlSpot> chartDataTanah = [];
  List<FlSpot> chartDataUdara = [];
  List<FlSpot> chartDataSuhu = [];
  List<FlSpot> chartDataCo2 = [];
  double _timeIndex = 0;

  bool isNodeSensorOnline = false; 
  bool isPompaOnline = false;      
  bool isKipasOnline = false;      

  Timer? _sensorTimeout;

  DashboardProvider() {}

  void initMqtt() {
    _mqttService.connect(
      onMessageReceived: (data) {
        _timeIndex++; 

        // TANGKAP DATA SENSOR 
        if (data['temp'] != null) suhu = (data['temp'] as num).toStringAsFixed(1);
        if (data['hum'] != null) kelembabanUdara = (data['hum'] as num).toStringAsFixed(1);
        if (data['soil'] != null) kelembabanTanah = (data['soil'] as num).toStringAsFixed(0);
        if (data['co2'] != null) kualitasUdara = (data['co2'] as num).toStringAsFixed(0); 

        // TANGKAP DATA LEVEL AIR & JALANKAN LOGIKA NOTIFIKASI
        if (data['dist'] != null) {
          double distance = (data['dist'] as num).toDouble();
          levelAir = distance.toStringAsFixed(0);

          // =========================================================
          // 2. TAMBAHAN LOGIKA NOTIFIKASI AIR (ANTI-SPAM)
          // =========================================================
          if (distance > 14) {
            if (_statusAirTerakhir != "Sedikit") {
              NotificationService.showNotification(
                id: 1, 
                title: "⚠️ Peringatan Kritis", 
                body: "Pasokan air tersisa sedikit!"
              );
              _statusAirTerakhir = "Sedikit"; // Kunci agar tidak spam
            }
          } 
          else if (distance >= 11 && distance <= 14) {
            if (_statusAirTerakhir != "Setengah") {
              NotificationService.showNotification(
                id: 1, 
                title: "💧 Info Pasokan Air", 
                body: "Pasokan air tersisa setengah."
              );
              _statusAirTerakhir = "Setengah"; // Kunci agar tidak spam
            }
          } 
          else if (distance < 11) {
            // Reset status jika air sudah diisi penuh lagi
            _statusAirTerakhir = "Aman";
          }
          // =========================================================
        }

       // TANGKAP DATA DAN MASUKKAN KE TITIK GRAFIK
        if (data['temp'] != null) {
          chartDataSuhu.add(FlSpot(_timeIndex, (data['temp'] as num).toDouble()));
          if (chartDataSuhu.length > 20) chartDataSuhu.removeAt(0); 
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

        // CEK STATUS AKTUATOR DARI RELAY
        if (data['pump'] != null) isPompaOnline = data['pump'] == 'ON'; 
        if (data['fan'] != null) isKipasOnline = data['fan'] == 'ON';

        // CEK STATUS ESP32 (Fitur Timeout)
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
    _mqttService.publishMessage("mewing/relay/pump", msg); 
    isPompaOnline = turnOn;
    notifyListeners();
  }

  void manualToggleKipas(bool turnOn) {
    String msg = turnOn ? "ON" : "OFF";
    _mqttService.publishMessage("mewing/relay/fan", msg); 
    isKipasOnline = turnOn;
    notifyListeners();
  }
}