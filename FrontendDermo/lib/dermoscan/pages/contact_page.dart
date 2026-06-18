import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../const/app_colors.dart';
import '../myWidgets/nav_bar.dart';
import '../myWidgets/gradient_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class _ContactState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const _ContactState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  _ContactState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) =>
      _ContactState(
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        errorMessage: errorMessage,
      );
}

class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key});

  @override
  ConsumerState<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  String _selectedCategory = 'Question générale';
  _ContactState _formState = const _ContactState();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _categories = [
    'Question générale',
    'Problème technique',
    'Résultat d\'analyse',
    'Confidentialité / Données',
    'Partenariat médical',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _formState = _formState.copyWith(
      isLoading: true,
      errorMessage: null,
    );
  });

  try {
    await FirebaseFirestore.instance
        .collection('contacts')
        .add({
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'category': _selectedCategory,
      'subject': _subjectCtrl.text.trim(),
      'message': _messageCtrl.text.trim(),

      'created_at': FieldValue.serverTimestamp(),

      'platform': 'flutter_web',
      'status': 'new',
    });

    if (!mounted) return;

    setState(() {
      _formState = _formState.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _formState = _formState.copyWith(
        isLoading: false,
        errorMessage:
            'Erreur lors de l’envoi du message : $e',
      );
    });
  }
}

  void _reset() {
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _emailCtrl.clear();
    _subjectCtrl.clear();
    _messageCtrl.clear();
    setState(() {
      _selectedCategory = 'Question générale';
      _formState = const _ContactState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: const AppNavBar(),
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _ContactHeader(),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 80 : 24,
                  vertical: 48,
                ),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _ContactInfo(),
                          ),
                          const SizedBox(width: 60),
                          Expanded(
                            flex: 3,
                            child: _formState.isSuccess
                                ? _SuccessMessage(onReset: _reset)
                                : _ContactForm(
                                    formKey: _formKey,
                                    firstNameCtrl: _firstNameCtrl,
                                    lastNameCtrl: _lastNameCtrl,
                                    emailCtrl: _emailCtrl,
                                    subjectCtrl: _subjectCtrl,
                                    messageCtrl: _messageCtrl,
                                    selectedCategory: _selectedCategory,
                                    categories: _categories,
                                    onCategoryChanged: (v) => setState(
                                        () => _selectedCategory = v ?? _selectedCategory),
                                    formState: _formState,
                                    onSubmit: _submit,
                                  ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _ContactInfo(),
                          const SizedBox(height: 40),
                          _formState.isSuccess
                              ? _SuccessMessage(onReset: _reset)
                              : _ContactForm(
                                  formKey: _formKey,
                                  firstNameCtrl: _firstNameCtrl,
                                  lastNameCtrl: _lastNameCtrl,
                                  emailCtrl: _emailCtrl,
                                  subjectCtrl: _subjectCtrl,
                                  messageCtrl: _messageCtrl,
                                  selectedCategory: _selectedCategory,
                                  categories: _categories,
                                  onCategoryChanged: (v) => setState(
                                      () => _selectedCategory = v ?? _selectedCategory),
                                  formState: _formState,
                                  onSubmit: _submit,
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

class _ContactHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.contact_support_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(height: 20),
          const Text(
            'Contactez-nous',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Notre équipe est disponible pour répondre\nà toutes vos questions.',
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

class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.email_outlined, 'Email', 'support@dermoscan.ai',
          'Réponse sous 24h ouvrées'),
      (Icons.access_time_rounded, 'Disponibilité',
          'Lun – Ven, 9h – 18h', 'Heure de Tunis (GMT+1)'),
      (Icons.language_rounded, 'Langues', 'Français, Arabe, Anglais',
          'Support multilingue'),
      (Icons.security_rounded, 'Confidentialité',
          'Vos données sont protégées', 'Conformité RGPD'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nous sommes là pour vous',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Que vous ayez une question sur un résultat d\'analyse, '
          'un problème technique ou simplement besoin de conseils, '
          'notre équipe est là pour vous aider.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 32),
        ...items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$1,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.$3,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.$4,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Avertissement médical
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.warning.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pour toute urgence médicale, contactez directement '
                  'un médecin ou le service d\'urgences. DermoScan AI '
                  'est un outil d\'aide, pas un service médical.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
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

class _ContactForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController subjectCtrl;
  final TextEditingController messageCtrl;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onCategoryChanged;
  final _ContactState formState;
  final VoidCallback onSubmit;

  const _ContactForm({
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.subjectCtrl,
    required this.messageCtrl,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.formState,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Envoyer un message',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tous les champs marqués * sont obligatoires.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),

            // Nom + Prénom
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: firstNameCtrl,
                    label: 'Prénom *',
                    hint: 'Votre prénom',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _Field(
                    controller: lastNameCtrl,
                    label: 'Nom *',
                    hint: 'Votre nom',
                    icon: Icons.badge_outlined,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Email
            _Field(
              controller: emailCtrl,
              label: 'Email *',
              hint: 'votre@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email requis';
                if (!v.contains('@')) return 'Email invalide';
                return null;
              },
            ),

            const SizedBox(height: 18),

            // Catégorie
            _Label(label: 'Catégorie *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              onChanged: onCategoryChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.category_outlined,
                    color: AppColors.textSecondary, size: 20),
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
            ),

            const SizedBox(height: 18),

            // Sujet
            _Field(
              controller: subjectCtrl,
              label: 'Sujet *',
              hint: 'Résumez votre demande en quelques mots',
              icon: Icons.subject_rounded,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Sujet requis';
                if (v.length < 5) return 'Sujet trop court';
                return null;
              },
            ),

            const SizedBox(height: 18),

            // Message
            _Label(label: 'Message *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: messageCtrl,
              maxLines: 5,
              maxLength: 1000,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Message requis';
                if (v.length < 20)
                  return 'Message trop court (minimum 20 caractères)';
                return null;
              },
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText:
                    'Décrivez votre question ou problème en détail...',
                hintStyle: TextStyle(
                    color: AppColors.textLight, fontSize: 14),
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.8),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.malignant),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 8),

            if (formState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.malignantLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.malignant.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.malignant, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formState.errorMessage!,
                        style: const TextStyle(
                            color: AppColors.malignant, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),

            // Bouton envoyer
            GradientButton(
              label: 'Envoyer le message',
              icon: Icons.send_rounded,
              isLoading: formState.isLoading,
              onTap: formState.isLoading ? null : onSubmit,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessMessage extends StatefulWidget {
  final VoidCallback onReset;
  const _SuccessMessage({required this.onReset});

  @override
  State<_SuccessMessage> createState() => _SuccessMessageState();
}

class _SuccessMessageState extends State<_SuccessMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.benign.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.benign.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.benignLight,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.benign.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.benign, size: 44),
            ),
            const SizedBox(height: 24),
            const Text(
              'Message envoyé !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Merci pour votre message. Notre équipe\nvous répondra dans les 24 heures ouvrées.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Envoyer un autre message',
              variant: GradientButtonVariant.outlined,
              icon: Icons.refresh_rounded,
              onTap: widget.onReset,
              width: 260,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  const _Label({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label: label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: AppColors.textLight, fontSize: 14),
            prefixIcon:
                Icon(icon, color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.malignant),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.malignant, width: 1.8),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}