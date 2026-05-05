// Result returned by the on-device recognition model.
// Represents what artifact the camera is currently pointing at.
class ArtifactResult {
  final String id;         // matches ArtifactProfile.id
  final String name;       // human-readable artifact name
  final double confidence; // 0.0 – 1.0

  const ArtifactResult({
    required this.id,
    required this.name,
    required this.confidence,
  });

  @override
  String toString() => 'ArtifactResult(id: $id, name: $name, confidence: $confidence)';
}
