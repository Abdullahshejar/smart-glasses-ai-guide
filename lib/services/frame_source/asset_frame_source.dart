import 'dart:async';
import 'frame_source.dart';

// Emits a single static frame from a bundled asset image.
// No network or device needed — safe default for demos and testing.
//
// To use a real image: add your JPEG to assets/images/ and update
// the path in AppConfig or pass it directly to this constructor.
class AssetFrameSource implements FrameSource {
  final String assetPath;

  final _controller = StreamController<FrameData>.broadcast();

  AssetFrameSource({
    this.assetPath = 'assets/images/sample_artifact.jpg',
  });

  @override
  Future<void> start() async {
    // Small delay to simulate startup before emitting
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_controller.isClosed) {
      _controller.add(FrameData.fromAsset(assetPath));
    }
  }

  @override
  Stream<FrameData> get stream => _controller.stream;

  @override
  void stop() {
    if (!_controller.isClosed) _controller.close();
  }
}
