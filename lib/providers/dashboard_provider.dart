import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // IMPORT FL_CHART
import '../services/mqtt_service.dart';

class DashboardProvider with ChangeNotifier {
  final MqttService _mqttService = MqttService();

  String kelembabanTanah = "--";
  String kelembabanUdara = "--"; 
  String suhu = "--";
  String levelAir = "--";

  String selectedChart = 'Tanah';

  // --- VARIABEL UNTUK GRAFIK ---
  List<FlSpot> chartDataTanah = [];
  List<FlSpot> chartDataUdara = [];
  List<FlSpot> chartDataSuhu = [];
  double _timeIndex = 0; // Sumbu X yang terus berjalan

  bool isSensorAOnline = true;
  bool isPompaOnline = false;
  bool isSensorBOnline = false;
  bool isKipasOnline = true;

  DashboardProvider() {}

  void initMqtt() {
    _mqttService.connect(
      onMessageReceived: (data) {
        // Tambah waktu untuk sumbu X tiap ada data masuk
        _timeIndex++; 

        // TANGKAP DATA DAN MASUKKAN KE TITIK GRAFIK
        if (data['temp'] != null) {
          double valSuhu = (data['temp'] as num).toDouble();
          suhu = valSuhu.toStringAsFixed(1); 
          chartDataSuhu.add(FlSpot(_timeIndex, valSuhu));
          if (chartDataSuhu.length > 20) chartDataSuhu.removeAt(0); // Batasi 20 titik
        }
        
        if (data['hum'] != null) {
          double valHum = (data['hum'] as num).toDouble();
          kelembabanUdara = valHum.toStringAsFixed(1);
          chartDataUdara.add(FlSpot(_timeIndex, valHum));
          if (chartDataUdara.length > 20) chartDataUdara.removeAt(0);
        }

        if (data['soil'] != null) {
          double valSoil = (data['soil'] as num).toDouble();
          kelembabanTanah = valSoil.toStringAsFixed(0); // Soil bilangan bulat
          chartDataTanah.add(FlSpot(_timeIndex, valSoil));
          if (chartDataTanah.length > 20) chartDataTanah.removeAt(0);
        }
        
        if (data['dist'] != null) {
          double valDist = (data['dist'] as num).toDouble();
          levelAir = valDist.toStringAsFixed(1);
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