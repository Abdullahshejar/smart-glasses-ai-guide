// Full metadata about a painting — matches the structure in paintings.json.
// This is passed as context to the LLM (Flask backend or direct API).
class ArtifactProfile {
  final String id;          // painting key, e.g. "woman_doves"
  final String name;        // display name, e.g. "Woman of the Doves"
  final String artist;
  final int year;
  final String style;
  final String medium;
  final String description;
  final String story;
  final List<String> facts;

  const ArtifactProfile({
    required this.id,
    required this.name,
    required this.artist,
    required this.year,
    required this.style,
    required this.medium,
    required this.description,
    required this.story,
    required this.facts,
  });

  // Plain-text summary injected into the LLM prompt (used by direct API mode)
  String toContextString() {
    final factLines = facts.map((f) => '- $f').join('\n');
    return '''
Painting: $name
Artist: $artist
Year: $year
Style: $style
Medium: $medium
Description: $description
Story: $story
Key facts:
$factLines
''';
  }

  factory ArtifactProfile.fromJson(Map<String, dynamic> json) {
    return ArtifactProfile(
      id:          json['id']          as String,
      name:        json['name']        as String,
      artist:      json['artist']      as String,
      year:        json['year']        as int,
      style:       json['style']       as String,
      medium:      json['medium']      as String,
      description: json['description'] as String,
      story:       json['story']       as String,
      facts:       List<String>.from(json['facts'] as List),
    );
  }
}
