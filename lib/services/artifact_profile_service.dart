import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/artifact_profile.dart';

// Loads artifact metadata from the bundled JSON file.
// Returns the full profile for a given artifact ID so it can be
// passed as context to the LLM service.
class ArtifactProfileService {
  // In-memory cache — loaded once at startup
  final Map<String, ArtifactProfile> _profiles = {};

  bool get isLoaded => _profiles.isNotEmpty;

  // Load all profiles from the bundled JSON asset into memory.
  // Call once at app start before any lookups.
  Future<void> loadProfiles() async {
    final jsonString = await rootBundle.loadString('lib/data/mock_artifacts.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    for (final item in jsonList) {
      final profile = ArtifactProfile.fromJson(item as Map<String, dynamic>);
      _profiles[profile.id] = profile;
    }
  }

  // Return the profile for the given artifact ID, or null if not found.
  ArtifactProfile? getProfile(String artifactId) {
    return _profiles[artifactId];
  }

  // Return all loaded profiles (useful for End Tour summary).
  List<ArtifactProfile> get allProfiles => _profiles.values.toList();
}
