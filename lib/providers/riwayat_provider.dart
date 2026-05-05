import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class RiwayatProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool isLoading = true;
  String selectedFilter = '5 Menit'; // Default dropdown
  final List<String> filterOptions = ['5 Menit', '1 Hari', '1 Minggu', '1 Bulan'];

  // Wadah data untuk 3 grafik
  List<FlSpot> soilSpots = [];
  List<FlSpot> humSpots = [];
  List<FlSpot> tempSpots = [];

  // Wadah untuk nilai rata-rata
  double avgSoil = 0;
  double avgHum = 0;
  double avgTemp = 0;

  Future<void> fetchHistoryData() async {
    isLoading = true;
    notifyListeners();

    // 1. Tentukan batas waktu mundur
    DateTime threshold = DateTime.now();
    switch (selectedFilter) {
      case '5 Menit': threshold = DateTime.now().subtract(const Duration(minutes: 5)); break;
      case '1 Hari': threshold = DateTime.now().subtract(const Duration(days: 1)); break;
      case '1 Minggu': threshold = DateTime.now().subtract(const Duration(days: 7)); break;
      case '1 Bulan': threshold = DateTime.now().subtract(const Duration(days: 30)); break;
    }

    try {
      // 2. Tarik data dari Supabase
      final response = await _supabase
          .from('sensor_history')
          .select()
          .gte('created_at', threshold.toIso8601String())
          .order('created_at', ascending: true); // Ascending agar grafik jalan dari kiri ke kanan

      final data = response as List<dynamic>;

      // 3. Bersihkan data lama
      soilSpots.clear(); humSpots.clear(); tempSpots.clear();
      double sumSoil = 0, sumHum = 0, sumTemp = 0;

      // 4. Masukkan data baru ke titik FlSpot
      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        double soil = (item['soil'] ?? 0).toDouble();
        double hum = (item['hum'] ?? 0).toDouble();
        double temp = (item['temp'] ?? 0).toDouble();

        // Sumbu X pakai index (i), Sumbu Y pakai nilai sensor
        soilSpots.add(FlSpot(i.toDouble(), soil));
        humSpots.add(FlSpot(i.toDouble(), hum));
        tempSpots.add(FlSpot(i.toDouble(), temp));

        sumSoil += soil; sumHum += hum; sumTemp += temp;
      }

      // Hitung rata-rata jika data tidak kosong
      if (data.isNotEmpty) {
        avgSoil = sumSoil / data.length;
        avgHum = sumHum / data.length;
        avgTemp = sumTemp / data.length;
      } else {
        avgSoil = avgHum = avgTemp = 0;
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }

    isLoading = false;
    notifyListeners(); // Update UI
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    fetchHistoryData(); // Tarik data ulang dengan rentang waktu baru
  }
}