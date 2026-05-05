// A single saved interaction: one question asked about one artifact.
// Stored in memory by HistoryService and shown on the History screen.
class HistoryItem {
  final String artifactName;
  final String question;
  final String answer;
  final DateTime timestamp;

  const HistoryItem({
    required this.artifactName,
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  // Formatted time string for display (e.g. "14:32")
  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
