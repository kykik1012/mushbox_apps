// lib/widgets/profile_menu_item.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // Pastikan path ini sesuai dengan letak file warnamu

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap; // Tambahkan ini agar bisa menerima aksi klik dari luar

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Gunakan withValues(alpha: ...) untuk menggantikan withOpacity() yang deprecated
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)), 
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.dark1),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}