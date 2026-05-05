import '../models/history_item.dart';

// Stores all Q&A interactions during a tour session.
// Phase 4: in-memory only — cleared when the app restarts.
// Future phases: persist to shared_preferences or a local SQLite database.
class HistoryService {
  final List<HistoryItem> _items = [];

  // All saved interactions, newest first.
  List<HistoryItem> get items => List.unmodifiable(
        _items.reversed.toList(),
      );

  int get count => _items.length;

  // Save a new interaction.
  void save({
    required String artifactName,
    required String question,
    required String answer,
  }) {
    _items.add(HistoryItem(
      artifactName: artifactName,
      question: question,
      answer: answer,
      timestamp: DateTime.now(),
    ));
  }

  // Remove all items (called when starting a fresh tour).
  void clear() => _items.clear();
}
