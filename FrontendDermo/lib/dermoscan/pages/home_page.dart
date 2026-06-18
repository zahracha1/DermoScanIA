import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../const/app_colors.dart';
import '../const/app_routes.dart';
import '../myWidgets/nav_bar.dart';
import '../myWidgets/gradient_button.dart';
import '../myWidgets/feature_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _reviewIndex = 0;
  final CarouselSliderController _reviewController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroCover(isWide: isWide),

            _WhySection(isWide: isWide),

            _WhatYouKnowSection(isWide: isWide),

            _SaveYourLifeSection(isWide: isWide),

            _ReviewsSection(
              currentIndex: _reviewIndex,
              controller: _reviewController,
              onPageChanged: (i) => setState(() => _reviewIndex = i),
            ),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _HeroCover extends StatefulWidget {
  final bool isWide;
  const _HeroCover({required this.isWide});

  @override
  State<_HeroCover> createState() => _HeroCoverState();
}

class _HeroCoverState extends State<_HeroCover>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
          minHeight: widget.isWide ? 520 : 420),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: -80,
            bottom: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          // Contenu
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isWide ? 80 : 28,
              vertical: 60,
            ),
            child: widget.isWide
                ? Row(
                    children: [
                      Expanded(child: _HeroText(fade: _fade, slide: _slide)),
                      const SizedBox(width: 48),
                      Expanded(child: _HeroGraphic()),
                    ],
                  )
                : Column(
                    children: [
                      _HeroText(fade: _fade, slide: _slide),
                      const SizedBox(height: 40),
                      _HeroGraphic(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  const _HeroText({required this.fade, required this.slide});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'IA Médicale Certifiée',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Titre
            const Text(
              'DermoScan AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                height: 1.05,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Détection intelligente de\nlésions cutanées en 60 secondes',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Stats rapides
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _HeroStat(value: '97%', label: 'Précision'),
                _HeroStat(value: '58+', label: 'Maladies'),
                _HeroStat(value: '< 1 min', label: 'Résultat'),
              ],
            ),
            const SizedBox(height: 36),

            // Boutons CTA
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                Builder(
                  builder: (context) => GradientButton(
                    label: 'Analyser maintenant',
                    icon: Icons.biotech_rounded,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.check),
                    width: 220,
                    height: 52,
                    variant: GradientButtonVariant.outlined,
                    color: AppColors.malignant,
                    backgroundColor: AppColors.malignantLight,
                  ),
                ),
                Builder(
                  builder: (context) => GradientButton(
                    label: 'Comment ça marche',
                    icon: Icons.play_circle_outline_rounded,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.use),
                    width: 210,
                    height: 52,
                    variant: GradientButtonVariant.outlined,
                    color: AppColors.benign,
                    backgroundColor: AppColors.benignLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _HeroGraphic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.medical_services_rounded,
            color: Colors.white.withOpacity(0.9),
            size: 72,
          ),
          const SizedBox(height: 20),
          const Text(
            'Analyse en cours...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Barre de progression animée
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 0.87),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOut,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GraphicTag(label: 'Bénin', color: AppColors.benign),
              _GraphicTag(label: 'Analyse IA', color: Colors.white),
              _GraphicTag(label: 'Malin', color: AppColors.malignant),
            ],
          ),
        ],
      ),
    );
  }
}

class _GraphicTag extends StatelessWidget {
  final String label;
  final Color color;
  const _GraphicTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _WhySection extends StatelessWidget {
  final bool isWide;
  const _WhySection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.biotech_rounded,        'Détecte 58+ maladies', 'Inclut mélanome, cancer, acné et plus encore.'),
      (Icons.analytics_rounded,      'Précision > 97%',      'Basé sur IA et base de données clinique.'),
      (Icons.timer_rounded,          'Résultat en 1 minute', 'Analyse rapide, résultat fiable immédiat.'),
      (Icons.home_rounded,           'Dépistage à domicile',  'Effectuez un dépistage depuis chez vous.'),
      (Icons.support_agent_rounded,  'Consultant IA 24/7',   'Assistance intelligente disponible partout.'),
      (Icons.trending_up_rounded,    'Suivi dans le temps',  'Suivez l\'évolution de vos lésions.'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      child: Column(
        children: [
          _SectionBadge(label: 'POURQUOI NOUS CHOISIR ?'),
          const SizedBox(height: 10),
          const Text(
            'Pourquoi utiliser AI Dermatologist ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Développé avec des dermatologues et avancé par l\'intelligence artificielle.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: isWide ? 3 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isWide ? 1.7 : 4,
            children: List.generate(features.length, (i) {
              final f = features[i];
              return isWide
                  ? FeatureCard(
                      icon: f.$1,
                      title: f.$2,
                      description: f.$3,
                      animationDelay: i * 100,
                    )
                  : FeatureCardHorizontal(
                      icon: f.$1,
                      title: f.$2,
                      subtitle: f.$3,
                    );
            }),
          ),
        ],
      ),
    );
  }
}

class _WhatYouKnowSection extends StatelessWidget {
  final bool isWide;
  const _WhatYouKnowSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.warning_rounded,       'Cancer de la peau',        'Mélanome, BKK, BCC, etc.', AppColors.malignant),
      (Icons.watch_later_rounded,   'Lésions précancéreuses',   'Nævus bleu et dysplasique, etc.', AppColors.warning),
      (Icons.grain_rounded,         'Types d\'acné',            'Toutes formes et sévérités.', const Color(0xFF9B59B6)),
      (Icons.spa_rounded,           'Formations bénignes',      'Grains de beauté, angiomes, dermatofibromes.', AppColors.benign),
      (Icons.coronavirus_rounded,   'Virus du papillome',       'Verrues, papillomes, mollusques.', const Color(0xFF3498DB)),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      color: const Color(0xFFF0F4FF),
      child: Column(
        children: [
          _SectionBadge(label: 'ANALYSE COMPLÈTE'),
          const SizedBox(height: 16),
          const Text(
            'Que savez-vous en 1 minute ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Notre IA identifie une large gamme de conditions cutanées\navec une précision clinique.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),

          // Cartes de conditions
          isWide
              ? Row(
                  children: items
                      .map((item) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _ConditionCard(
                                icon: item.$1,
                                title: item.$2,
                                subtitle: item.$3,
                                color: item.$4,
                              ),
                            ),
                          ))
                      .toList(),
                )
              : Column(
                  children: items
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FeatureCardHorizontal(
                              icon: item.$1,
                              title: item.$2,
                              subtitle: item.$3,
                              color: item.$4,
                            ),
                          ))
                      .toList(),
                ),

          const SizedBox(height: 44),
          Builder(
            builder: (context) => GradientButton(
              label: 'Essayer maintenant',
              icon: Icons.biotech_rounded,
              onTap: () => Navigator.pushNamed(context, AppRoutes.check),
              width: 220,
              height: 52,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ConditionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveYourLifeSection extends StatelessWidget {
  final bool isWide;
  const _SaveYourLifeSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('2+',   'personnes meurent du cancer de la peau chaque heure dans le monde'),
      ('1/50', 'personnes développeront un cancer de la peau dans leur vie'),
      ('99%',  'taux de survie à 5 ans si le mélanome est détecté tôt'),
      ('#2',   'cancer le plus fréquent chez les 15-29 ans'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 72,
      ),
      child: Column(
        children: [
          _SectionBadge(label: 'SANTÉ & VIE', color: AppColors.malignant),
          const SizedBox(height: 16),
          const Text(
            'L\'IA Dermatologist\npeut sauver votre vie',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 40),

          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Texte gauche
                    Expanded(
                      flex: 3,
                      child: _SaveYourLifeText(),
                    ),
                    const SizedBox(width: 60),
                    // Stats droite
                    Expanded(
                      flex: 2,
                      child: _StatsPanel(stats: stats),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _SaveYourLifeText(),
                    const SizedBox(height: 32),
                    _StatsPanel(stats: stats),
                  ],
                ),
        ],
      ),
    );
  }
}

class _SaveYourLifeText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final points = [
      'Le cancer de la peau est le cancer le plus courant dans le monde.',
      'Le mélanome est un cancer de la peau qui peut se propager plus tôt et plus rapidement que les autres cancers cutanés.',
      'Le mélanome est le deuxième cancer le plus fréquent chez les hommes et femmes de 15 à 29 ans.',
      'Lorsqu\'il est détecté tôt, le taux de survie à 5 ans pour le mélanome est de 99%.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'L\'une des maladies les plus dangereuses que l\'IA Dermatologist peut aider à identifier est le cancer de la peau.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 24),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.malignant.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.priority_high_rounded,
                      color: AppColors.malignant, size: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Highlight box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.benign.withOpacity(0.1),
                AppColors.benign.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.benign.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.benign, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'DermoScan AI vous aide à détecter ces lésions tôt,\nquand le traitement est le plus efficace.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final List<(String, String)> stats;
  const _StatsPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stats
          .map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.malignant.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.malignant.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    s.$1,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.malignant,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      s.$2,
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
          )
          .toList(),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final int currentIndex;
  final CarouselSliderController controller;
  final ValueChanged<int> onPageChanged;

  const _ReviewsSection({
    required this.currentIndex,
    required this.controller,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final reviews = [
      _ReviewData(
        name: 'Ranim.K.',
        role: 'Patiente',
        text: 'J\'ai utilisé DermoScan AI pour une tache suspecte. Résultat en 45 secondes, bénin confirmé ensuite par mon dermatologue. Impressionnant !',
        rating: 5,
        initials: 'RK',
        color: AppColors.primary,
      ),
      _ReviewData(
        name: 'Dr. Karim B.',
        role: 'Dermatologue',
        text: 'Outil remarquable pour le triage préliminaire. Je le recommande à mes patients pour surveiller leurs lésions entre les consultations.',
        rating: 5,
        initials: 'KB',
        color: const Color(0xFF9B59B6),
      ),
      _ReviewData(
        name: 'Amine S.',
        role: 'Utilisateur',
        text: 'Interface très claire, résultat rapide. Le fait de recevoir des conseils avec le résultat est vraiment utile. Application indispensable.',
        rating: 4,
        initials: 'AS',
        color: const Color(0xFF2ECC71),
      ),
      _ReviewData(
        name: 'Zahra C.',
        role: 'Infirmière',
        text: 'DermoScan AI nous aide à prioriser les cas urgents. La précision de 97% est impressionnante et les résultats sont très clairs.',
        rating: 5,
        initials: 'ZC',
        color: const Color(0xFFE74C3C),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 72),
      color: const Color(0xFFF0F4FF),
      child: Column(
        children: [
          _SectionBadge(label: 'TÉMOIGNAGES'),
          const SizedBox(height: 16),
          const Text(
            'Ce que disent nos utilisateurs',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),
          CarouselSlider(
            carouselController: controller,
            options: CarouselOptions(
              height: 220,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              enlargeCenterPage: true,
              viewportFraction: 0.75,
              onPageChanged: (i, _) => onPageChanged(i),
            ),
            items: reviews
                .map((r) => _ReviewCard(review: r))
                .toList(),
          ),
          const SizedBox(height: 20),
          // Indicateurs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              reviews.length,
              (i) => GestureDetector(
                onTap: () => controller.animateToPage(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: i == currentIndex ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == currentIndex
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewData {
  final String name;
  final String role;
  final String text;
  final int rating;
  final String initials;
  final Color color;
  const _ReviewData({
    required this.name,
    required this.role,
    required this.text,
    required this.rating,
    required this.initials,
    required this.color,
  });
}

class _ReviewCard extends StatelessWidget {
  final _ReviewData review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Étoiles
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Texte
          Expanded(
            child: Text(
              '"${review.text}"',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.55,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 14),
          // Avatar + Nom
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: review.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: review.color.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    review.initials,
                    style: TextStyle(
                      color: review.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    review.role,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 48,
      ),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        children: [
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _FooterBrand()),
                    const SizedBox(width: 60),
                    Expanded(child: _FooterLinks()),
                    const SizedBox(width: 40),
                    Expanded(child: _FooterContact()),
                  ],
                )
              : Column(
                  children: [
                    _FooterBrand(),
                    const SizedBox(height: 32),
                    _FooterLinks(),
                    const SizedBox(height: 32),
                    _FooterContact(),
                  ],
                ),
          const SizedBox(height: 40),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            '© ${DateTime.now().year} DermoScan AI. Tous droits réservés. '
            'Cet outil est une aide à la décision et ne remplace pas l\'avis médical.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'DermoScan AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Classification intelligente de lésions cutanées\npropulsée par l\'intelligence artificielle.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Navigation',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        ...['Accueil', 'Comment utiliser', 'Analyser', 'Historique', 'Contact'].map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                final routes = {
                  'Accueil': AppRoutes.home,
                  'Comment utiliser': AppRoutes.use,
                  'Analyser': AppRoutes.check,
                  'Historique': AppRoutes.history,
                  'Contact': AppRoutes.contact,
                };
                Navigator.pushNamed(context, routes[link]!);
              },
              child: Text(
                link,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        ...['support@dermoscan.ai', '+216 28 647 227'].map(
          (info) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              info,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ),
        ),
        
      ],
    );
  }
}

class _SectionBadge extends StatelessWidget {
  final String label;
  final Color? color;
  const _SectionBadge({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}