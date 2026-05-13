import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class RiwayatProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool isLoading = true;
  String selectedFilter = '5 Menit';
  final List<String> filterOptions = ['5 Menit', '1 Hari', '1 Minggu', '1 Bulan'];

  // Wadah data untuk 4 grafik (Tambahan CO2)
  List<FlSpot> soilSpots = [];
  List<FlSpot> humSpots = [];
  List<FlSpot> tempSpots = [];
  List<FlSpot> co2Spots = []; // TAMBAHAN

  // Wadah untuk nilai rata-rata (Tambahan CO2)
  double avgSoil = 0;
  double avgHum = 0;
  double avgTemp = 0;
  double avgCo2 = 0; // TAMBAHAN

  Future<void> fetchHistoryData() async {
    isLoading = true;
    notifyListeners();

    DateTime threshold = DateTime.now();
    switch (selectedFilter) {
      case '5 Menit': threshold = DateTime.now().subtract(const Duration(minutes: 5)); break;
      case '1 Hari': threshold = DateTime.now().subtract(const Duration(days: 1)); break;
      case '1 Minggu': threshold = DateTime.now().subtract(const Duration(days: 7)); break;
      case '1 Bulan': threshold = DateTime.now().subtract(const Duration(days: 30)); break;
    }

    try {
      final response = await _supabase
          .from('sensor_history')
          .select()
          .gte('created_at', threshold.toUtc().toIso8601String()) 
          .order('created_at', ascending: true);

      final data = response as List<dynamic>;

      // Bersihkan data lama
      soilSpots.clear(); humSpots.clear(); tempSpots.clear(); co2Spots.clear();
      double sumSoil = 0, sumHum = 0, sumTemp = 0, sumCo2 = 0;

      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        double soil = (item['soil'] ?? 0).toDouble();
        double hum = (item['hum'] ?? 0).toDouble();
        double temp = (item['temp'] ?? 0).toDouble();
        double co2 = (item['co2'] ?? 0).toDouble(); // TAMBAHAN BACA CO2

        soilSpots.add(FlSpot(i.toDouble(), soil));
        humSpots.add(FlSpot(i.toDouble(), hum));
        tempSpots.add(FlSpot(i.toDouble(), temp));
        co2Spots.add(FlSpot(i.toDouble(), co2)); // TAMBAHAN TITIK CO2

        sumSoil += soil; sumHum += hum; sumTemp += temp; sumCo2 += co2;
      }

      if (data.isNotEmpty) {
        avgSoil = sumSoil / data.length;
        avgHum = sumHum / data.length;
        avgTemp = sumTemp / data.length;
        avgCo2 = sumCo2 / data.length; // RATA-RATA CO2
      } else {
        avgSoil = avgHum = avgTemp = avgCo2 = 0;
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    fetchHistoryData();
  }
}