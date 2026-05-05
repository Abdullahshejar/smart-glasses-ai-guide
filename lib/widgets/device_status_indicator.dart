import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// Shows the Raspberry Pi connection status at the top of the screen
class DeviceStatusIndicator extends StatelessWidget {
  final bool isConnected;

  const DeviceStatusIndicator({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? AppTheme.success : AppTheme.error;
    final label = isConnected ? 'Pi Connected' : 'Pi Disconnected';
    final icon = isConnected ? Icons.wifi : Icons.wifi_off;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
