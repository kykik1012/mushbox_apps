import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/riwayat_provider.dart';
import '../theme/app_colors.dart';

class RiwayatGrafikScreen extends StatefulWidget {
  const RiwayatGrafikScreen({super.key});

  @override
  State<RiwayatGrafikScreen> createState() => _RiwayatGrafikScreenState();
}

class _RiwayatGrafikScreenState extends State<RiwayatGrafikScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RiwayatProvider>(context, listen: false).fetchHistoryData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Riwayat Grafik Sensor', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<RiwayatProvider>(
        builder: (context, prov, child) {
          return Column(
            children: [
              // HEADER DROPDOWN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rentang Waktu:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: prov.selectedFilter,
                          items: prov.filterOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) prov.setFilter(newValue);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // LIST GRAFIK
              Expanded(
                child: prov.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.dark1))
                    : prov.soilSpots.isEmpty
                        ? const Center(child: Text('Belum ada data pada rentang waktu ini'))
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _buildChartCard('Riwayat Kelembaban Tanah', 'Data ${prov.selectedFilter}', prov.avgSoil, prov.soilSpots, const Color(0xFF163832)),
                              const SizedBox(height: 16),
                              _buildChartCard('Riwayat Kelembaban Udara', 'Data ${prov.selectedFilter}', prov.avgHum, prov.humSpots, const Color(0xFF8EB69B)),
                              const SizedBox(height: 16),
                              _buildChartCard('Riwayat Suhu', 'Data ${prov.selectedFilter}', prov.avgTemp, prov.tempSpots, Colors.orange),
                            ],
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget Pembantu untuk membuat kartu grafik
  Widget _buildChartCard(String title, String subtitle, double avg, List<FlSpot> spots, Color lineColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade300)), // Warna pudar seperti di desain
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rata-rata', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  Text(avg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false), // Sembunyikan grid sesuai desain
                titlesData: const FlTitlesData(show: false), // Sembunyikan label axis
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: lineColor.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}