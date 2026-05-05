import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSensorService {
  final _supabase = Supabase.instance.client;

  // Mengambil data berdasarkan batas waktu yang diminta
  Future<List<dynamic>> fetchSensorHistory(DateTime threshold) async {
    try {
      final response = await _supabase
          .from('sensor_history')
          .select()
          .gte('created_at', threshold.toIso8601String())
          .order('created_at', ascending: false); // Urutkan dari yang terbaru
          
      return response as List<dynamic>;
    } catch (e) {
      throw Exception('Gagal mengambil data sensor: $e');
    }
  }
}