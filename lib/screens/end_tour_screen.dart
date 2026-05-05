import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/history_item.dart';
import '../services/share_email_service.dart';

// End of tour screen — shows a summary and action buttons.
// Receives history items via route arguments (same pattern as HistoryScreen).
class EndTourScreen extends StatefulWidget {
  const EndTourScreen({super.key});

  @override
  State<EndTourScreen> createState() => _EndTourScreenState();
}

class _EndTourScreenState extends State<EndTourScreen> {
  final _shareService = ShareEmailService();

  bool _sharingInProgress = false;

  // Unique artifacts visited (deduplicated by name)
  List<String> _uniqueArtifacts(List<HistoryItem> items) {
    final seen = <String>{};
    return items
        .map((i) => i.artifactName)
        .where((name) => seen.add(name))
        .toList();
  }

  Future<void> _onShare(List<HistoryItem> items) async {
    setState(() => _sharingInProgress = true);
    await _shareService.share(items);
    if (!mounted) return;
    setState(() => _sharingInProgress = false);
    _showSnack('Summary copied to log (share_plus coming soon)');
  }

  Future<void> _onEmail(List<HistoryItem> items) async {
    setState(() => _sharingInProgress = true);
    await _shareService.sendEmail(items);
    if (!mounted) return;
    setState(() => _sharingInProgress = false);
    _showSnack('Email logged (url_launcher coming soon)');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items =
        (ModalRoute.of(context)?.settings.arguments as List<HistoryItem>?) ?? [];
    final artifacts = _uniqueArtifacts(items);

    return Scaffold(
      appBar: AppBar(title: const Text('End of Tour')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ────────────────────────────────────────────
            _banner(items.length, artifacts.length),
            const SizedBox(height: 24),

            // ── Artifacts visited ─────────────────────────────────
            if (artifacts.isNotEmpty) ...[
              _sectionHeader('Artifacts Visited'),
              const SizedBox(height: 10),
              ...artifacts.map((name) => _artifactTile(name)),
              const SizedBox(height: 24),
            ],

            // ── Interactions summary ──────────────────────────────
            if (items.isNotEmpty) ...[
              _sectionHeader('Interactions'),
              const SizedBox(height: 10),
              ...items.asMap().entries.map(
                    (e) => _interactionTile(e.key + 1, e.value),
                  ),
              const SizedBox(height: 24),
            ],

            // ── Action buttons ────────────────────────────────────
            _sectionHeader('Share Your Experience'),
            const SizedBox(height: 12),
            _actionButton(
              icon: Icons.share_outlined,
              label: 'Share Summary',
              color: AppTheme.primary,
              onPressed: _sharingInProgress ? null : () => _onShare(items),
            ),
            const SizedBox(height: 12),
            _actionButton(
              icon: Icons.email_outlined,
              label: 'Send via Email',
              color: AppTheme.primary,
              onPressed: _sharingInProgress ? null : () => _onEmail(items),
            ),
            const SizedBox(height: 12),
            _actionButton(
              icon: Icons.feedback_outlined,
              label: 'Leave Feedback',
              color: Colors.white24,
              onPressed: () => _showSnack('Feedback form coming soon'),
            ),
            const SizedBox(height: 24),

            // ── Back to home ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('Back to Home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.onSurface,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Banner card ──────────────────────────────────────────────────
  Widget _banner(int interactions, int artifactCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.6),
            AppTheme.primary.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.museum_outlined, color: AppTheme.accent, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Tour Complete!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statBadge('$artifactCount', 'Artifact${artifactCount != 1 ? 's' : ''}'),
              const SizedBox(width: 12),
              _statBadge('$interactions', 'Question${interactions != 1 ? 's' : ''}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent),
            ),
            TextSpan(
              text: label,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section header ───────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppTheme.accent,
        letterSpacing: 1.2,
      ),
    );
  }

  // ── Artifact tile ────────────────────────────────────────────────
  Widget _artifactTile(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 16, color: AppTheme.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    color: AppTheme.onSurface, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ── Interaction tile ─────────────────────────────────────────────
  Widget _interactionTile(int index, HistoryItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$index. ${item.artifactName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.onSurface),
                  ),
                  const Spacer(),
                  Text(item.formattedTime,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.question,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Action button ────────────────────────────────────────────────
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
