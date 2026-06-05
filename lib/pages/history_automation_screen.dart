import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/otomasi_provider.dart';

class HistoryAutomationScreen extends StatefulWidget {
  const HistoryAutomationScreen({super.key});

  @override
  State<HistoryAutomationScreen> createState() => _HistoryAutomationScreenState();
}

class _HistoryAutomationScreenState extends State<HistoryAutomationScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil data riwayat sesaat sebelum layar dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OtomasiProvider>(context, listen: false).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: const Text('Riwayat Aktivitas Perangkat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Consumer<OtomasiProvider>(
        builder: (context, prov, child) {
          if (prov.isHistoryLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF163832)));
          }

          if (prov.automationHistory.isEmpty) {
            return const Center(
              child: Text("Belum ada riwayat aktivitas perangkat.", style: TextStyle(color: Colors.grey)),
            );
          }

          return RefreshIndicator(
            onRefresh: () => prov.fetchHistory(),
            color: const Color(0xFF163832),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prov.automationHistory.length,
              itemBuilder: (context, index) {
                final log = prov.automationHistory[index];
                final String aktuator = log['aktuator'] ?? 'Perangkat';
                final String perintah = log['perintah'] ?? 'OFF';
                
                // Memformat string timestamp mentah menjadi tanggal & jam lokal yang mudah dibaca
                final DateTime dateTime = DateTime.parse(log['created_at']).toLocal();
                final String formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
                final String formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";

                final bool isTurnOn = perintah == 'ON';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Lingkaran ikon dengan warna dinamis sesuai aksi (Hijau untuk menyala, Abu-abu untuk mati)
                          CircleAvatar(
                            backgroundColor: isTurnOn ? const Color(0xFFE8F0ED) : Colors.red.shade50,
                            radius: 20,
                            child: Icon(
                              aktuator == 'Kipas' ? Icons.mode_fan_off : Icons.water_drop,
                              color: isTurnOn ? const Color(0xFF163832) : Colors.red,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                aktuator,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isTurnOn ? const Color(0xFF163832) : Colors.grey[400],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isTurnOn ? "BERHASIL HIDUP" : "BERHASIL MATI",
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Kolom penunjuk waktu di bagian kanan kartu
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formattedTime,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF163832)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}