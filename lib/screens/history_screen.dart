import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/history_item.dart';

// Displays all Q&A interactions saved during the current tour session.
// Receives the list via route arguments pushed from HomeScreen.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Receive history items passed from HomeScreen via Navigator arguments
    final items =
        (ModalRoute.of(context)?.settings.arguments as List<HistoryItem>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('History (${items.length})'),
      ),
      body: items.isEmpty ? _emptyState() : _list(items),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────
  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 56, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'No interactions yet',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Press Talk on the home screen to ask a question.',
            style: TextStyle(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Interaction list ─────────────────────────────────────────────
  Widget _list(List<HistoryItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _HistoryCard(
        item: items[index],
        index: index + 1,
      ),
    );
  }
}

// ── Single history card ──────────────────────────────────────────────
class _HistoryCard extends StatefulWidget {
  final HistoryItem item;
  final int index;

  const _HistoryCard({required this.item, required this.index});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ───────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Index badge
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.index}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Artifact name + timestamp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.artifactName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.formattedTime,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // Expand / collapse chevron
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),

              // ── Question (always visible) ─────────────────────
              const SizedBox(height: 12),
              _labelRow(Icons.mic_none_outlined, 'Question'),
              const SizedBox(height: 4),
              Text(
                item.question,
                style: const TextStyle(
                    color: AppTheme.onSurface, fontSize: 14, height: 1.4),
              ),

              // ── Answer (shown when expanded) ──────────────────
              if (_expanded) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                _labelRow(Icons.auto_awesome, 'Answer'),
                const SizedBox(height: 4),
                Text(
                  item.answer,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.accent),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              color: AppTheme.accent,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8),
        ),
      ],
    );
  }
}
