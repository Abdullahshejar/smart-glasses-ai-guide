import 'dart:developer' as dev;
import '../models/history_item.dart';

// Generates a tour summary and prepares it for sharing or emailing.
//
// Phase 4: builds the summary text only — no real sending.
// Future phases: integrate share_plus for native share sheet,
//   and url_launcher to open the mail client with a pre-filled body.
class ShareEmailService {
  // Build a human-readable summary of the full tour.
  String buildSummary(List<HistoryItem> history) {
    if (history.isEmpty) {
      return 'No interactions were recorded during this tour.';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== Museum Tour Summary ===');
    buffer.writeln('Total questions asked: ${history.length}');
    buffer.writeln('');

    for (int i = 0; i < history.length; i++) {
      final item = history[i];
      buffer.writeln('--- ${i + 1}. ${item.artifactName} (${item.formattedTime}) ---');
      buffer.writeln('Q: ${item.question}');
      buffer.writeln('A: ${item.answer}');
      buffer.writeln('');
    }

    buffer.writeln('Thank you for visiting!');
    return buffer.toString();
  }

  // Simulate sharing the summary (logs it for now).
  Future<void> share(List<HistoryItem> history) async {
    final summary = buildSummary(history);
    dev.log('[Share] Summary ready:\n$summary', name: 'ShareEmailService');
    // Future: await Share.share(summary, subject: 'My Museum Tour');
  }

  // Simulate sending via email (logs it for now).
  Future<void> sendEmail(List<HistoryItem> history, {String? toAddress}) async {
    final summary = buildSummary(history);
    dev.log('[Email] To: ${toAddress ?? 'user@example.com'}\n$summary',
        name: 'ShareEmailService');
    // Future: final uri = Uri(scheme: 'mailto', path: toAddress,
    //           queryParameters: {'subject': 'Museum Tour', 'body': summary});
    //         await launchUrl(uri);
  }
}
