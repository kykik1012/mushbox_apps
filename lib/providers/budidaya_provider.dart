import 'package:flutter/material.dart';
import '../services/supabase_sensor_service.dart';

class BudidayaProvider with ChangeNotifier {
  final SupabaseSensorService _sensorService = SupabaseSensorService();

  bool isLoading = true;
  List<dynamic> historyData = [];

  double avgTemp = 0.0;
  double avgHum = 0.0;
  double avgSoil = 0.0;
  double avgDist = 0.0;

  final List<String> timeFilters = ['1 Jam', '3 Jam', '12 Jam', '1 Hari', '3 Hari', '1 Minggu'];
  String selectedFilter = '1 Jam';

  // Fungsi utama untuk mengambil data dan menghitung rata-rata
  Future<void> fetchData(String filter) async {
    selectedFilter = filter;
    isLoading = true;
    notifyListeners(); // Beritahu UI untuk menampilkan animasi loading

    try {
      DateTime threshold;
      final now = DateTime.now();

      // Atur mundur waktu sesuai filter yang dipilih
      switch (filter) {
        case '1 Jam': threshold = now.subtract(const Duration(hours: 1)); break;
        case '3 Jam': threshold = now.subtract(const Duration(hours: 3)); break;
        case '12 Jam': threshold = now.subtract(const Duration(hours: 12)); break;
        case '1 Hari': threshold = now.subtract(const Duration(days: 1)); break;
        case '3 Hari': threshold = now.subtract(const Duration(days: 3)); break;
        case '1 Minggu': threshold = now.subtract(const Duration(days: 7)); break;
        default: threshold = now.subtract(const Duration(hours: 1));
      }

      // Ambil data dari Service
      final data = await _sensorService.fetchSensorHistory(threshold);

      // Hitung Rata-rata
      double sumTemp = 0, sumHum = 0, sumSoil = 0, sumDist = 0;
      if (data.isNotEmpty) {
        for (var item in data) {
          sumTemp += (item['temp'] ?? 0) as num;
          sumHum += (item['hum'] ?? 0) as num;
          sumSoil += (item['soil'] ?? 0) as num;
          sumDist += (item['dist'] ?? 0) as num;
        }
        avgTemp = sumTemp / data.length;
        avgHum = sumHum / data.length;
        avgSoil = sumSoil / data.length;
        avgDist = sumDist / data.length;
      } else {
        avgTemp = avgHum = avgSoil = avgDist = 0;
      }

      historyData = data;
    } catch (e) {
      debugPrint('Error BudidayaProvider: $e');
    } finally {
      isLoading = false;
      notifyListeners(); // Beritahu UI untuk menghilangkan animasi loading
    }
  }
}