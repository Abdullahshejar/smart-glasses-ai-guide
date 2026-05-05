import '../core/config/app_config.dart';
import '../models/artifact_result.dart';
import 'recognition/recognition_backend.dart';
import 'recognition/mock_recognition_backend.dart';
import 'recognition/live_recognition_backend.dart';

// Coordinates artifact recognition using a swappable [RecognitionBackend].
// Reads [appConfig.recognitionMode] on every call so switching modes in
// Settings takes effect on the next recognition pass — no restart needed.
class RecognitionService {
  RecognitionBackend? _backend;
  RecognitionMode? _loadedMode;

  bool get isReady => _backend?.isLoaded ?? false;

  // Load (or reload) the backend matching the current config mode.
  Future<void> loadModel() async {
    final mode = appConfig.recognitionMode;
    _backend = _buildBackend(mode);
    await _backend!.load();
    _loadedMode = mode;
  }

  // Run recognition on the given frame bytes.
  // Automatically reloads the backend if the mode has changed since last load.
  Future<ArtifactResult?> recognize(List<int>? frameBytes) async {
    final currentMode = appConfig.recognitionMode;

    // Reload backend if mode has changed in settings
    if (_backend == null || _loadedMode != currentMode) {
      await loadModel();
    }

    return _backend!.recognize(frameBytes);
  }

  RecognitionBackend _buildBackend(RecognitionMode mode) {
    switch (mode) {
      case RecognitionMode.mock:
        return MockRecognitionBackend();
      case RecognitionMode.live:
        return LiveRecognitionBackend();
    }
  }
}
