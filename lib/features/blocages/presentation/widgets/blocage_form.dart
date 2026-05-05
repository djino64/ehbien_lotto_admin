// lib/features/blocages/presentation/widgets/blocage_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/core/utils/validators.dart';
import 'package:ehbien_lotto_admin/features/blocages/presentation/providers/blocages_provider.dart';
import 'package:ehbien_lotto_admin/features/blocages/presentation/widgets/blocage_scope_selector.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';

class BlocageForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const BlocageForm({super.key, required this.onSuccess});

  @override
  ConsumerState<BlocageForm> createState() => _BlocageFormState();
}

class _BlocageFormState extends ConsumerState<BlocageForm> {
  final _formKey    = GlobalKey<FormState>();
  final _bouleCtrl  = TextEditingController();

  BlocageScope _scope        = BlocageScope.global;
  String?      _typeJeu;
  String?      _agentId;
  String?      _succursaleId;
  String?      _tirageId;
  bool         _permanent    = true;
  DateTime?    _expiresAt;
  String?      _errorMessage;

  static const _typesJeu = [
    'borlette',
    'mariage',
    'lotto3',
    'sel',
  ];

  @override
  void dispose() {
    _bouleCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    final error = await ref
        .read(blocagesNotifierProvider.notifier)
        .createBlocage(
          boule:        _bouleCtrl.text.trim(),
          typeJeu:      _typeJeu,
          agentId:      _scope == BlocageScope.parAgent ? _agentId : null,
          succursaleId: _scope == BlocageScope.parSuccursale
              ? _succursaleId
              : null,
          tirageId:     _scope == BlocageScope.parTirage ? _tirageId : null,
          global:       _scope == BlocageScope.global,
          permanent:    _permanent,
          expiresAt:    _permanent ? null : _expiresAt,
        );

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      _bouleCtrl.clear();
      setState(() {
        _scope     = BlocageScope.global;
        _typeJeu   = null;
        _agentId   = null;
        _permanent = true;
        _expiresAt = null;
      });
      widget.onSuccess();
    }
  }

  Future<void> _pickExpiry() async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context:     context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate:   now,
      lastDate:    now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() => _expiresAt = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(blocagesNotifierProvider).isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Boule + Type jeu ──────────────────────────
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bouleCtrl,
                  decoration: const InputDecoration(
                    labelText:  'Numéro / Boule',
                    prefixIcon: Icon(Icons.numbers_rounded),
                    hintText:   'ex: 13',
                  ),
                  keyboardType: TextInputType.number,
                  validator:    (v) =>
                      Validators.required(v, label: 'La boule'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue:      _typeJeu,
                  onChanged:  (v) => setState(() => _typeJeu = v),
                  decoration: const InputDecoration(
                    labelText:  'Type de jeu (optionnel)',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  hint: const Text('Tous les jeux'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tous les jeux'),
                    ),
                    ..._typesJeu.map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_jeuLabel(t)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Portée ────────────────────────────────────
          BlocageScopeSelector(
            value:                  _scope,
            onScopeChanged:         (v) => setState(() => _scope = v),
            onAgentChanged:         (v) => setState(() => _agentId = v),
            onSuccursaleChanged:    (v) => setState(() => _succursaleId = v),
            onTirageChanged:        (v) => setState(() => _tirageId = v),
            selectedAgentId:        _agentId,
            selectedSuccursaleId:   _succursaleId,
            selectedTirageId:       _tirageId,
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Durée ─────────────────────────────────────
          _buildDurationSection(),

          // ── Erreur ────────────────────────────────────
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 4),
              decoration: BoxDecoration(
                color:        AppColors.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.danger.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.danger,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color:   AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // ── Bouton ────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _submit,
              icon: isLoading
                  ? const SizedBox(
                      width:  16,
                      height: 16,
                      child:  CircularProgressIndicator(
                        strokeWidth: 2,
                        color:       Colors.white,
                      ),
                    )
                  : const Icon(Icons.block_rounded, size: 18),
              label: Text(
                isLoading ? 'Création...' : 'Créer le blocage',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durée du blocage',
          style: TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w600,
            color:      AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _DurationOption(
                label:    'Permanent',
                subtitle: 'Sans date d\'expiration',
                icon:     Icons.all_inclusive_rounded,
                selected: _permanent,
                onTap:    () => setState(() {
                  _permanent = true;
                  _expiresAt = null;
                }),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _DurationOption(
                label:    'Temporaire',
                subtitle: _expiresAt != null
                    ? 'Expire le ${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year}'
                    : 'Choisir une date',
                icon:     Icons.timer_rounded,
                selected: !_permanent,
                onTap: () async {
                  setState(() => _permanent = false);
                  await _pickExpiry();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _jeuLabel(String t) => switch (t) {
    'borlette' => 'Borlette',
    'mariage'  => 'Mariage',
    'lotto3'   => 'Lotto 3',
    'sel'      => 'Sèl',
    _          => t,
  };
}

class _DurationOption extends StatelessWidget {
  final String   label;
  final String   subtitle;
  final IconData icon;
  final bool     selected;
  final VoidCallback onTap;

  const _DurationOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : Colors.grey,
              size:  20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w600,
                      color:      selected
                          ? AppColors.primary
                          : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color:    Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size:  18,
              ),
          ],
        ),
      ),
    );
  }
}