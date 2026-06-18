import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../const/app_colors.dart';
import '../const/app_routes.dart';
import '../myWidgets/nav_bar.dart';
import '../myWidgets/gradient_button.dart';
import '../myWidgets/feature_card.dart';

class UsePage extends ConsumerWidget {
  const UsePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 80 : 24,
                vertical: 60,
              ),
              child: Column(
                children: [
                  _SectionHeader(
                    tag: 'GUIDE',
                    title: 'Comment utiliser\nAI Dermatologist ?',
                    subtitle:
                        'Trois étapes simples pour obtenir votre analyse cutanée en moins d\'une minute.',
                  ),
                  const SizedBox(height: 56),
                  isWide
                      ? _StepsRow()
                      : _StepsColumn(),
                ],
              ),
            ),

            _TrustSection(isWide: isWide),

            _CtaSection(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            
           
          ),
          const Text(
            'Commencer en\n3 étapes simples',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune expertise médicale requise.\nL\'IA analyse votre lésion et vous fournit un résultat en 60 secondes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _StepCard(step: _steps[0], index: 0)),
        _StepConnector(),
        Expanded(child: _StepCard(step: _steps[1], index: 1)),
        _StepConnector(),
        Expanded(child: _StepCard(step: _steps[2], index: 2)),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Row(
        children: List.generate(
          6,
          (i) => Container(
            width: 6,
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(i % 2 == 0 ? 0.4 : 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_steps.length, (i) {
        return Column(
          children: [
            _StepCard(step: _steps[i], index: i),
            if (i < _steps.length - 1) ...[
              const SizedBox(height: 8),
              Container(
                width: 2,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.4),
                      AppColors.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      }),
    );
  }
}

class _StepData {
  final String number;
  final String title;
  final String description;
  final String tip;
  final IconData icon;
  final Color color;

  const _StepData({
    required this.number,
    required this.title,
    required this.description,
    required this.tip,
    required this.icon,
    required this.color,
  });
}

const _steps = [
  _StepData(
    number: '01',
    title: 'Prenez une photo',
    description:
        'Photographiez la lésion cutanée avec votre appareil photo ou importez une image existante depuis votre galerie.',
    tip: 'Restez à moins de 10 cm, gardez au point et centrez uniquement la lésion (sans poils, rides ou autres objets).',
    icon: Icons.photo_camera_rounded,
    color: Color(0xFF3498DB),
  ),
  _StepData(
    number: '02',
    title: 'Identifiez et envoyez',
    description:
        'Envoyez votre photo à l\'intelligence artificielle. Le système va l\'analyser et vous envoyer une évaluation du risque.',
    tip: 'L\'IA applique automatiquement un prétraitement de l\'image pour améliorer la précision du diagnostic.',
    icon: Icons.send_rounded,
    color: Color(0xFF9B59B6),
  ),
  _StepData(
    number: '03',
    title: 'Recevez votre résultat',
    description:
        'Obtenez le résultat en moins de 60 secondes avec des conseils sur les prochaines étapes à suivre.',
    tip: 'Le résultat indique si la lésion est bénigne ou maligne avec un pourcentage de confiance.',
    icon: Icons.assignment_turned_in_rounded,
    color: Color(0xFF2ECC71),
  ),
];

class _StepCard extends StatefulWidget {
  final _StepData step;
  final int index;
  const _StepCard({required this.step, required this.index});

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.step;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: s.color.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: s.color.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Numéro + Icône
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: s.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(s.icon, color: s.color, size: 28),
                  ),
                  const Spacer(),
                  Text(
                    s.number,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: s.color.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Titre
              Text(
                s.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                s.description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),

              // Conseil encadré
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: s.color.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: s.color.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_forward_rounded,
                        color: s.color, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.tip,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustSection extends StatelessWidget {
  final bool isWide;
  const _TrustSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.biotech_rounded, '62+', 'Conditions détectées', AppColors.primary),
      (Icons.analytics_rounded, '97%', 'Précision clinique', const Color(0xFF9B59B6)),
      (Icons.security_rounded, '100%', 'Privé & sécurisé', const Color(0xFF2ECC71)),
      (Icons.devices_rounded, '24/7', 'Disponible partout', const Color(0xFF3498DB)),
      (Icons.timer_rounded, '< 1 min', 'Résultat rapide', const Color(0xFFF39C12)),
      (Icons.trending_up_rounded, '∞', 'Suivi dans le temps', AppColors.accent),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 60,
      ),
      color: const Color(0xFFF8FAFF),
      child: Column(
        children: [
          _SectionHeader(
            tag: 'CONFIANCE',
            title: 'Pourquoi les utilisateurs\nnous font confiance ?',
            subtitle: 'Une technologie médicale rigoureuse,'
                ' accessible à tous.',
          ),
          const SizedBox(height: 48),
          isWide
              ? GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.2,
                  children: items
                      .map((item) => _TrustCard(
                            icon: item.$1,
                            value: item.$2,
                            label: item.$3,
                            color: item.$4,
                          ))
                      .toList(),
                )
              : Column(
                  children: items
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TrustCard(
                              icon: item.$1,
                              value: item.$2,
                              label: item.$3,
                              color: item.$4,
                            ),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _TrustCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Prêt à commencer ?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Analysez votre première lésion maintenant.\nC\'est gratuit et prend moins d\'une minute.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            label: 'Analyser maintenant',
            icon: Icons.biotech_rounded,
            onTap: () => Navigator.pushNamed(context, AppRoutes.check),
            width: 240,
            height: 52,
            variant: GradientButtonVariant.outlined,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String tag;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.tag,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}