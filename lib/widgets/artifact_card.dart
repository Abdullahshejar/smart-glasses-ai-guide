import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ArtifactCard extends StatelessWidget {
  final String? artifactName;
  final String? artifactId;
  final double? confidence;

  const ArtifactCard({
    super.key,
    this.artifactName,
    this.artifactId,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final hasResult = artifactName != null && confidence != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Painting image (full width, shown when a painting is selected)
          if (hasResult && artifactId != null)
            Image.asset(
              'assets/images/$artifactId.jpg',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, e) => Container(
                height: 100,
                color: AppTheme.primary.withValues(alpha: 0.15),
                child: const Center(
                  child: Icon(Icons.image_outlined, color: Colors.white24, size: 40),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.museum_outlined, color: AppTheme.accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasResult ? artifactName! : 'No painting selected',
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      hasResult
                          ? _ConfidenceBar(confidence: confidence!)
                          : const Text(
                              'Pick a painting from the list above',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double confidence;
  const _ConfidenceBar({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).toStringAsFixed(1);
    final color = confidence >= 0.8
        ? AppTheme.success
        : confidence >= 0.5
            ? AppTheme.warning
            : AppTheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confidence: $percent%',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
