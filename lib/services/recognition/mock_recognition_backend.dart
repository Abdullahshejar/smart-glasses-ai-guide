import '../../models/artifact_result.dart';
import 'recognition_backend.dart';

// Returns rotating mock results for all frames.
// No model files required — always safe to use.
class MockRecognitionBackend implements RecognitionBackend {
  bool _loaded = false;
  int _index = 0;

  // Cycles through real painting IDs that match paintings.json / mock_artifacts.json
  static const _results = [
    ArtifactResult(id: 'woman_doves',         name: 'Woman of the Doves',      confidence: 0.93),
    ArtifactResult(id: 'woman_smoke',         name: 'Woman in Smoke',          confidence: 0.87),
    ArtifactResult(id: 'seashell',            name: 'Seashell',                confidence: 0.91),
    ArtifactResult(id: 'bridge_sunset',       name: 'Bridge Sunset',           confidence: 0.85),
    ArtifactResult(id: 'abstract_landscape',  name: 'Abstract Landscape',      confidence: 0.89),
  ];

  @override
  Future<void> load() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _loaded = true;
  }

  @override
  Future<ArtifactResult?> recognize(List<int>? frameBytes) async {
    if (!_loaded) return null;
    await Future.delayed(const Duration(milliseconds: 800)); // simulate inference
    final result = _results[_index % _results.length];
    _index++;
    return result;
  }

  @override
  bool get isLoaded => _loaded;
}
