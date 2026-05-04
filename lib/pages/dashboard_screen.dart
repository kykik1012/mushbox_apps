import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/device_status_item.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
            Text('Rabu, 29 Apr 2026', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. GRID METRIK SENSOR
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                // Menggunakan Consumer spesifik untuk bagian ini agar tidak render ulang semua
                Consumer<DashboardProvider>(
                  builder: (context, prov, child) => MetricCard(
                    title: 'Kelembaban Tanah', value: prov.kelembabanTanah, unit: '%',
                    icon: Icons.water_drop_outlined, iconColor: const Color(0xFF163832), trend: '+3%', isTrendPositive: true,
                  ),
                ),
                Consumer<DashboardProvider>(
                  builder: (context, prov, child) => MetricCard(
                    title: 'Kelembaban Udara', value: prov.kelembabanUdara, unit: '%',
                    icon: Icons.air, iconColor: const Color(0xFF8EB69B), trend: '+5%', isTrendPositive: true,
                  ),
                ),
                Consumer<DashboardProvider>(
                  builder: (context, prov, child) => MetricCard(
                    title: 'Suhu', value: prov.suhu, unit: '°C',
                    icon: Icons.thermostat_outlined, iconColor: Colors.orange, trend: '-2°', isTrendPositive: false,
                  ),
                ),
                Consumer<DashboardProvider>(
                  builder: (context, prov, child) => MetricCard(
                    title: 'Level Air', value: prov.levelAir, unit: '%',
                    icon: Icons.waves, iconColor: Colors.blue, trend: '-8%', isTrendPositive: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. GRAFIK (Placeholder sementara sebelum pakai fl_chart)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Grafik Real-time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Data hari ini', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      // Tombol Toggle Chart
                      Consumer<DashboardProvider>(
                        builder: (context, prov, child) => Row(
                          children: ['Tanah', 'Udara', 'Suhu'].map((mode) {
                            bool isActive = prov.selectedChart == mode;
                            return GestureDetector(
                              onTap: () => prov.setChartMode(mode),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF163832) : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  mode,
                                  style: TextStyle(
                                    color: isActive ? Colors.white : Colors.grey[600],
                                    fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  // --- MULAI DARI SINI: Ganti tulisan "Tempat grafik..." dengan ini ---
                  const SizedBox(height: 16),
                  Consumer<DashboardProvider>(
                    builder: (context, prov, child) {
                      // 1. Siapkan data dan warna berdasarkan tab yang dipilih
                      List<FlSpot> currentData = [];
                      Color lineColor = const Color(0xFF163832); // Default Hijau Gelap

                      if (prov.selectedChart == 'Tanah') {
                        currentData = prov.chartDataTanah;
                        lineColor = const Color(0xFF163832);
                      } else if (prov.selectedChart == 'Udara') {
                        currentData = prov.chartDataUdara;
                        lineColor = const Color(0xFF8EB69B);
                      } else if (prov.selectedChart == 'Suhu') {
                        currentData = prov.chartDataSuhu;
                        lineColor = Colors.orange;
                      }

                      // 2. Jika belum ada data dari ESP32, tampilkan efek loading
                      if (currentData.isEmpty) {
                        return const SizedBox(
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF163832),
                            ),
                          ),
                        );
                      }

                      // 3. Tampilkan Grafik
                      return SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              getDrawingHorizontalLine: (value) => const FlLine(
                                color: Colors.black12,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              ),
                              getDrawingVerticalLine: (value) => const FlLine(
                                color: Colors.black12,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              ),
                            ),
                            titlesData: const FlTitlesData(
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              // Sembunyikan jam X sementara karena ESP32 nge-spam tiap 2 detik
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: currentData,
                                isCurved: true, // Garis melengkung halus
                                color: lineColor,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false), // Sembunyikan titik bulat
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: lineColor.withOpacity(0.1), // Efek bayangan di bawah garis
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // --- SAMPAI SINI ---
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. STATUS PERANGKAT
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status Perangkat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Consumer<DashboardProvider>(
                    builder: (context, prov, child) => Column(
                      children: [
                        DeviceStatusItem(deviceName: 'Sensor Area A', isOnline: prov.isSensorAOnline, icon: Icons.wifi),
                        DeviceStatusItem(deviceName: 'Pompa Utama', isOnline: prov.isPompaOnline, icon: Icons.water_drop),
                        DeviceStatusItem(deviceName: 'Sensor Area B', isOnline: prov.isSensorBOnline, icon: Icons.wifi_off),
                        DeviceStatusItem(deviceName: 'Kipas Ventilasi', isOnline: prov.isKipasOnline, icon: Icons.mode_fan_off),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}