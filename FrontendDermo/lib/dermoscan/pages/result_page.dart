import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../const/app_colors.dart';
import '../const/app_routes.dart';
import '../myWidgets/nav_bar.dart';
import '../models/analysis_result.dart';
import '../providers/analysis_provider.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisProvider);
    final result = state.result;

    if (result == null) {
      return Scaffold(
        appBar: const AppNavBar(),
        body: const Center(child: Text('Aucun résultat disponible')),
      );
    }

    final isMalignant = result.isMalignant;
    final mainColor = isMalignant ? AppColors.malignant : AppColors.benign;
    final bgColor = isMalignant
        ? AppColors.malignantLight
        : AppColors.benignLight;

    return Scaffold(
      appBar: const AppNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Icône de résultat
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: mainColor, width: 3),
                      ),
                      child: Icon(
                        isMalignant
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        color: mainColor,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.labelFr,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confiance : ${result.confidence.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        color: mainColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Barre de progression
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: result.confidence / 100),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        builder: (context, value, _) =>
                            LinearProgressIndicator(
                          value: value,
                          backgroundColor: mainColor.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(mainColor),
                          minHeight: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image analysée
                  if (state.selectedImageBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        state.selectedImageBytes!,
                         fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Détails
                  _DetailCard(
                    title: 'Probabilité de malignité',
                    value: '${(result.probability * 100).toStringAsFixed(1)}%',
                    icon: Icons.analytics_outlined,
                    color: mainColor,
                  ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 24),

                  // Conseil
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0F4FF), Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.medical_information_outlined,
                                color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Recommandation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          result.advice,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                 
                  const SizedBox(height: 28),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(analysisProvider.notifier).reset();
                            Navigator.pushNamed(context, AppRoutes.check);
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Nouvelle analyse'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                                color: AppColors.primary),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.history),
                          icon: const Icon(Icons.history_rounded),
                          label: const Text('Historique'),
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}