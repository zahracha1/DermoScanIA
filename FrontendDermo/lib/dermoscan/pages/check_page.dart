import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../const/app_colors.dart';
import '../const/app_routes.dart';
import '../myWidgets/nav_bar.dart';
import '../providers/analysis_provider.dart';
import '../providers/history_provider.dart';

class CheckPage extends ConsumerStatefulWidget {
  const CheckPage({super.key});

  @override
  ConsumerState<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends ConsumerState<CheckPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseController,
            curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 90,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      ref.read(analysisProvider.notifier).selectImage(bytes, picked.name);
    }
  }

  Future<void> _analyze() async {
    final state = ref.read(analysisProvider);
    if (state.selectedImageBytes == null) return;

    await ref.read(analysisProvider.notifier)
        .analyzeImage(imageBytes: state.selectedImageBytes);

    final newState = ref.read(analysisProvider);
    if (newState.status == AnalysisStatus.success &&
        newState.result != null) {
      await ref.read(historyProvider.notifier)
          .saveResult(newState.result!);
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisProvider);

    return Scaffold(
      appBar: const AppNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Titre
            const Text(
              'Analyser une lésion',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Importez une photo claire de la lésion cutanée',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Zone d'affichage de l'image
            _ImagePreview(
              imageBytes: state.selectedImageBytes,
              pulseAnimation: _pulseAnimation,
              onPickGallery: () => _pickImage(ImageSource.gallery),
              onPickCamera: () => _pickImage(ImageSource.camera),
            ),

            const SizedBox(height: 28),

     
            if (state.selectedImageBytes == null) ...[
              _PickButton(
                icon: Icons.photo_library_rounded,
                label: 'Choisir depuis la galerie',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(height: 12),
             
            ],


            const SizedBox(height: 20),
            _PhotoTips(),

            const SizedBox(height: 28),


            if (state.selectedImageBytes != null)
              _AnalyzeButton(
                isLoading: state.status == AnalysisStatus.loading,
                onTap: _analyze,
              ),

            // Erreur
            if (state.status == AnalysisStatus.error)
              _ErrorBanner(message: state.errorMessage ?? 'Erreur inconnue'),
          ],
        ),
      ),
    );
  }
}


class _ImagePreview extends StatelessWidget {
  final Uint8List? imageBytes;
  final Animation<double> pulseAnimation;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;

  const _ImagePreview({
    required this.imageBytes,
    required this.pulseAnimation,
    required this.onPickGallery,
    required this.onPickCamera,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: imageBytes == null ? pulseAnimation.value : 1.0,
        child: child,
      ),
      child: Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: imageBytes != null
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
            width: imageBytes != null ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.memory(imageBytes!,   fit: BoxFit.contain,),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 64,
                    color: AppColors.primary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune image sélectionnée',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuyez sur les boutons ci-dessous\npour choisir une photo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const _PickButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }
}

class _PhotoTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Conseils pour une meilleure analyse',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...[
            ' Distance < 10 cm de la lésion',
            ' Centrer uniquement la lésion',
            ' Bonne luminosité, pas de flash direct',
          ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  tip,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _AnalyzeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _AnalyzeButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Analyse en cours...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.biotech_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Lancer l\'analyse IA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.malignantLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.malignant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.malignant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.malignant, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}