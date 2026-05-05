import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AnswerCard extends StatelessWidget {
  final String? answer;
  final bool isSpeaking;
  final VoidCallback? onStop;
  final VoidCallback? onRepeat;

  const AnswerCard({
    super.key,
    this.answer,
    this.isSpeaking = false,
    this.onStop,
    this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.accent, size: 18),
                const SizedBox(width: 8),
                Text('Answer', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (isSpeaking)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up, color: AppTheme.success, size: 13),
                        SizedBox(width: 4),
                        Text('Speaking',
                            style: TextStyle(
                                color: AppTheme.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Answer body
            answer != null
                ? Text(answer!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.6))
                : const Text(
                    'Press Talk and ask a question about the artifact.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

            // Stop / Repeat buttons — only shown when there is an answer
            if (answer != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  if (isSpeaking)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onStop,
                        icon: const Icon(Icons.stop_circle_outlined, size: 18),
                        label: const Text('Stop'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  if (!isSpeaking)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRepeat,
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Repeat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accent,
                          side: const BorderSide(color: AppTheme.accent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
