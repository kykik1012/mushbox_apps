import 'package:flutter/material.dart';

class DeviceStatusItem extends StatelessWidget {
  final String deviceName;
  final bool isOnline;
  final IconData icon;

  const DeviceStatusItem({
    super.key,
    required this.deviceName,
    required this.isOnline,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: isOnline ? Colors.grey[700] : Colors.red[400], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              deviceName,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF051F20)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isOnline ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}