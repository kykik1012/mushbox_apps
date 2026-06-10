import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtomasiProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool isLoading = true;
  List<dynamic> triggers = [];
  List<dynamic> schedules = [];
  List<Map<String, dynamic>> automationHistory = [];
  bool isHistoryLoading = false;

  // Mengedit / Memperbarui Trigger yang sudah ada
  Future<void> updateTrigger(dynamic id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('otomasi_trigger').update(data).eq('id', id);
      await fetchData(); // Refresh list setelah mengedit
    } catch (e) {
      debugPrint('Error updating trigger: $e');
      rethrow;
    }
  }

  Future<void> fetchHistory() async {
    isHistoryLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('otomasi_riwayat')
          .select('*')
          .order('created_at', ascending: false); // Menampilkan data terbaru paling atas

      automationHistory = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {
      isHistoryLoading = false;
      notifyListeners();
    }
  }

  // Mengambil data saat aplikasi dibuka
  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    try {
      final triggerRes = await _supabase.from('otomasi_trigger').select();
      final jadwalRes = await _supabase.from('otomasi_jadwal').select();
      
      triggers = triggerRes;
      schedules = jadwalRes;
    } catch (e) {
      debugPrint('Error fetching otomasi: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Menyalakan / Mematikan Trigger
  Future<void> toggleTrigger(String id, bool currentValue) async {
    try {
      await _supabase.from('otomasi_trigger').update({'is_active': !currentValue}).eq('id', id);
      await fetchData(); // Refresh data
    } catch (e) {
      debugPrint('Error toggle trigger: $e');
    }
  }

  // Menghapus Trigger
  Future<void> deleteTrigger(String id) async {
    try {
      await _supabase.from('otomasi_trigger').delete().eq('id', id);
      await fetchData();
    } catch (e) {
      debugPrint('Error delete trigger: $e');
    }
  }

  // Fungsi untuk menambah trigger baru
  Future<void> addTrigger(Map<String, dynamic> data) async {
    try {
      await _supabase.from('otomasi_trigger').insert(data);
      await fetchData(); // Refresh list setelah menambah
    } catch (e) {
      debugPrint('Error adding trigger: $e');
      rethrow;
    }
  }

  // Menyalakan / Mematikan Jadwal Waktu
  Future<void> toggleJadwal(dynamic id, bool currentValue) async {
    try {
      await _supabase.from('otomasi_jadwal').update({'is_active': !currentValue}).eq('id', id);
      await fetchData();
    } catch (e) {
      debugPrint('Error toggle jadwal: $e');
    }
  }

  // Menghapus Jadwal Waktu
  Future<void> deleteJadwal(dynamic id) async {
    try {
      await _supabase.from('otomasi_jadwal').delete().eq('id', id);
      await fetchData();
    } catch (e) {
      debugPrint('Error delete jadwal: $e');
    }
  }

  // Menambah Jadwal Waktu Baru
  Future<void> addJadwal(Map<String, dynamic> data) async {
    try {
      await _supabase.from('otomasi_jadwal').insert(data);
      await fetchData();
    } catch (e) {
      debugPrint('Error adding jadwal: $e');
      rethrow;
    }
  }
}