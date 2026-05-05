import 'dart:typed_data';

// A single captured frame.
// Exactly one field will be non-null depending on the source type.
class FrameData {
  final Uint8List? bytes;      // raw image bytes — from Pi or URL fetch
  final String? assetPath;    // Flutter asset path — e.g. assets/images/...
  final String? networkUrl;   // network URL — for direct NetworkImage display

  const FrameData.fromBytes(Uint8List b)
      : bytes = b,
        assetPath = null,
        networkUrl = null;

  const FrameData.fromAsset(String path)
      : bytes = null,
        assetPath = path,
        networkUrl = null;

  const FrameData.fromUrl(String url)
      : bytes = null,
        assetPath = null,
        networkUrl = url;
}

// Common interface for all frame sources.
// Swap implementations (asset / url / Pi) without touching UI or services.
abstract class FrameSource {
  /// Start the source — begin emitting frames on [stream].
  Future<void> start();

  /// Stream of incoming frames. May emit once (static) or repeatedly (video).
  Stream<FrameData> get stream;

  /// Stop and release resources.
  void stop();
}
