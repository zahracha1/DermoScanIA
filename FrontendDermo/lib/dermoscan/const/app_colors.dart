// lib/dermoscan/const/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {

  static const Color primary      = Color(0xFF1F4B85);  // Bleu profond
  static const Color primaryLight = Color(0xFF2E6CC7);  // Bleu clair
  static const Color secondary    = Color(0xFF4A90D9);  // Bleu ciel doux
  static const Color accent       = Color(0xFF00B4D8);  // Cyan apaisant

  static const Color background   = Color(0xFFF8FAFF);  // Blanc légèrement bleuté
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceCard  = Color(0xFFF0F4FF);

  static const Color benign       = Color(0xFF2ECC71);  // Vert succès
  static const Color benignLight  = Color(0xFFD5F5E3);
  static const Color malignant    = Color(0xFFE74C3C);  // Rouge alerte
  static const Color malignantLight = Color(0xFFFDEDEC);
  static const Color warning      = Color(0xFFF39C12);  // Orange attention

  static const Color textPrimary  = Color(0xFF1A2340);
  static const Color textSecondary = Color(0xFF6B7A99);
  static const Color textLight    = Color(0xFFB0BEC5);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F4B85), Color(0xFF2E6CC7), Color(0xFF4A90D9)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0F4FF), Color(0xFFFFFFFF)],
  );
}