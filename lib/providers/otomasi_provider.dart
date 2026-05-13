import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtomasiProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool isLoading = true;
  List<dynamic> triggers = [];
  List<dynamic> schedules = [];

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

  // TODO: Nanti kita tambahkan fungsi toggleJadwal, deleteJadwal, dan Add ke sini
}