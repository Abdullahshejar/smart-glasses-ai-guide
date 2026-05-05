import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/frame_source/frame_source.dart';

// Displays the active frame from any FrameSource.
// Accepts a nullable [frame] — shows a placeholder when null.
class FramePreview extends StatelessWidget {
  final FrameData? frame;

  const FramePreview({super.key, this.frame});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 200,
        color: AppTheme.surface,
        child: frame == null ? _placeholder() : _frameWidget(frame!),
      ),
    );
  }

  // Shows the actual frame based on its type
  Widget _frameWidget(FrameData f) {
    if (f.bytes != null) {
      return Image.memory(f.bytes!, fit: BoxFit.cover,
          errorBuilder: (ctx, e, st) => _placeholder());
    }
    if (f.assetPath != null) {
      return Image.asset(f.assetPath!, fit: BoxFit.cover,
          errorBuilder: (ctx, e, st) => _assetMissingHint(f.assetPath!));
    }
    if (f.networkUrl != null) {
      return Image.network(f.networkUrl!, fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) =>
              progress == null ? child : _loadingSpinner(),
          errorBuilder: (ctx, e, st) => _placeholder());
    }
    return _placeholder();
  }

  // Default state — no frame available yet
  Widget _placeholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.videocam_outlined, size: 48, color: Colors.white24),
        SizedBox(height: 8),
        Text('Waiting for frame...',
            style: TextStyle(color: Colors.white38, fontSize: 13)),
      ],
    );
  }

  // Shown when the asset file doesn't exist on disk yet
  Widget _assetMissingHint(String path) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.broken_image_outlined, size: 40, color: Colors.white24),
        const SizedBox(height: 8),
        const Text('Sample image not found',
            style: TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(path,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white24, fontSize: 10)),
        ),
      ],
    );
  }

  Widget _loadingSpinner() {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
    );
  }
}
