import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../const/app_colors.dart';
import '../myWidgets/nav_bar.dart';
import '../providers/history_provider.dart';
import '../models/analysis_result.dart';
import 'dart:convert';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: const AppNavBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historique des analyses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatBadge(
                      label: 'Total',
                      value: history.length.toString(),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    _StatBadge(
                      label: 'Bénins',
                      value: history
                          .where((r) => !r.isMalignant)
                          .length
                          .toString(),
                      color: AppColors.benign,
                    ),
                    const SizedBox(width: 12),
                    _StatBadge(
                      label: 'Malins',
                      value: history
                          .where((r) => r.isMalignant)
                          .length
                          .toString(),
                      color: AppColors.malignant,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: history.isEmpty
                 ? const Center(
          child: CircularProgressIndicator(),
        )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return _HistoryCard(
                        result: history[index],
                        onDelete: () => ref
                            .read(historyProvider.notifier)
                            .deleteResult(history[index].id),
                      );
                    },
                  ),
          ),

          if (history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmClear(context, ref),
                  icon: const Icon(Icons.delete_sweep_rounded),
                  label: const Text('Vider l\'historique'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.malignant,
                    side: const BorderSide(color: AppColors.malignant),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vider l\'historique'),
        content: const Text(
            'Supprimer toutes les analyses ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearHistory();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.malignant,
            ),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AnalysisResult result;
  final VoidCallback onDelete;

  const _HistoryCard({required this.result, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color =
        result.isMalignant ? AppColors.malignant : AppColors.benign;
    final formatter = DateFormat('dd MMM yyyy • HH:mm', 'fr_FR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: result.imageBase64.isNotEmpty
      ? Image.memory(
          base64Decode(result.imageBase64),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        )
      : Container(
          width: 60,
          height: 60,
          color: AppColors.surfaceCard,
          child: Icon(
            result.isMalignant
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded,
            color: result.isMalignant
                ? AppColors.malignant
                : AppColors.benign,
            size: 28,
          ),
        ),
),
        title: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                result.labelFr,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${result.confidence.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            formatter.format(result.analyzedAt),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded,
              color: AppColors.textLight),
          tooltip: 'Supprimer',
        ),
      ),
    );
  }
}

//non
class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune analyse pour le moment',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos résultats apparaîtront ici',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
