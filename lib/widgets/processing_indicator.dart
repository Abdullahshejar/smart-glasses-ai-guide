import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// Shown while the app is running recognition or waiting for an LLM answer.
// Pass a [label] to describe the current operation.
class ProcessingIndicator extends StatelessWidget {
  final String label;

  const ProcessingIndicator({
    super.key,
    this.label = 'Processing...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
