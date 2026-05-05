import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budidaya_provider.dart';
import '../theme/app_colors.dart';

class BudidayaScreen extends StatefulWidget {
  const BudidayaScreen({super.key});

  @override
  State<BudidayaScreen> createState() => _BudidayaScreenState();
}

class _BudidayaScreenState extends State<BudidayaScreen> {
  @override
  void initState() {
    super.initState();
    // Tarik data 1 Jam terakhir saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BudidayaProvider>(context, listen: false).fetchData('1 Jam');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Riwayat Budidaya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      // Gunakan Consumer untuk mendengarkan perubahan data dari BudidayaProvider
      body: Consumer<BudidayaProvider>(
        builder: (context, prov, child) {
          return Column(
            children: [
              // 1. FILTER WAKTU
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: prov.timeFilters.length,
                  itemBuilder: (context, index) {
                    final filter = prov.timeFilters[index];
                    final isSelected = prov.selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        selectedColor: AppColors.dark1,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87, 
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        ),
                        backgroundColor: Colors.white,
                        onSelected: (selected) {
                          if (selected) {
                            prov.fetchData(filter); // Panggil fungsi di provider
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 2. KONTEN UTAMA
              Expanded(
                child: prov.isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.dark1))
                    : prov.historyData.isEmpty 
                        ? const Center(child: Text('Belum ada data di rentang waktu ini.', style: TextStyle(color: Colors.grey)))
                        : RefreshIndicator(
                            onRefresh: () => prov.fetchData(prov.selectedFilter),
                            color: AppColors.dark1,
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              children: [
                                const Text('Rata-rata Kondisi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                
                                // 3. KARTU RATA-RATA
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.5,
                                  children: [
                                    _buildAverageCard('Suhu', prov.avgTemp.toStringAsFixed(1), '°C', Icons.thermostat, Colors.orange),
                                    _buildAverageCard('Udara', prov.avgHum.toStringAsFixed(1), '%', Icons.air, Colors.blue),
                                    _buildAverageCard('Tanah', prov.avgSoil.toStringAsFixed(1), '%', Icons.water_drop, Colors.brown),
                                    _buildAverageCard('Air', prov.avgDist.toStringAsFixed(1), 'cm', Icons.waves, Colors.cyan),
                                  ],
                                ),

                                const SizedBox(height: 24),
                                const Text('Log Sensor Lengkap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),

                                // 4. DAFTAR RIWAYAT
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: prov.historyData.length,
                                  itemBuilder: (context, index) {
                                    final item = prov.historyData[index];
                                    final date = DateTime.parse(item['created_at']).toLocal();
                                    final timeString = DateFormat('dd MMM, HH:mm').format(date);

                                    return Card(
                                      elevation: 0,
                                      color: Colors.white,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: ListTile(
                                        leading: const CircleAvatar(
                                          backgroundColor: Color(0xFFE8F0ED),
                                          child: Icon(Icons.history, color: AppColors.dark1),
                                        ),
                                        title: Text(timeString, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        subtitle: Text(
                                          'Suhu: ${item['temp']}°C | Udara: ${item['hum']}% \nTanah: ${item['soil']}% | Jarak Air: ${item['dist']}cm',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget Pembantu untuk UI
  Widget _buildAverageCard(String title, String value, String unit, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark1)),
              const SizedBox(width: 2),
              Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}