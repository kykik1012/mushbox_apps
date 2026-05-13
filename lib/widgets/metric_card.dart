import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData iconData;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color valueColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.iconData,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.valueColor = const Color(0xFF163832),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // PERBAIKAN 1: Menggunakan spaceBetween agar konten otomatis mengisi ruang kosong tanpa menabrak batas
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          // 1. IKON DENGAN LATAR BELAKANG
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, size: 24, color: iconColor),
            ),
          ),
          
          // PERBAIKAN 2: Mengelompokkan angka dan teks di bawah agar selalu rapat
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Agar column ini tidak rakus ruang
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value, 
                    // PERBAIKAN 3: Ukuran font disesuaikan dari 32 menjadi 28 agar lebih aman untuk angka panjang
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit, 
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: valueColor),
                  ),
                ],
              ),
              
              const SizedBox(height: 4), 

              Text(
                title, 
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                maxLines: 1, // PERBAIKAN 4: Mencegah judul turun ke baris baru dan membuat overflow
                overflow: TextOverflow.ellipsis, // Jika judul kepanjangan, akan jadi titik-titik (...)
              ),
            ],
          ),
        ],
      ),
    );
  }
}