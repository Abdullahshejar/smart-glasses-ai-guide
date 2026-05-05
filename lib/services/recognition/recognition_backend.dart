import '../../models/artifact_result.dart';

// Pluggable interface for artifact recognition.
// RecognitionService holds one backend at a time and delegates to it.
// Swap implementations without changing any UI or service logic.
abstract class RecognitionBackend {
  /// Load the backend — e.g. warm up a model or initialise a client.
  Future<void> load();

  /// Run recognition on raw frame bytes.
  /// [frameBytes] — JPEG/PNG bytes from the active FrameSource.
  /// Returns null if the backend is not ready or confidence is too low.
  Future<ArtifactResult?> recognize(List<int>? frameBytes);

  bool get isLoaded;
}
