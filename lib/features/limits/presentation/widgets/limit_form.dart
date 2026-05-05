// lib/features/limits/presentation/widgets/limit_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/core/utils/validators.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/limits/presentation/providers/limits_provider.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/providers/tirages_provider.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';

class LimitForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const LimitForm({super.key, required this.onSuccess});

  @override
  ConsumerState<LimitForm> createState() => _LimitFormState();
}

class _LimitFormState extends ConsumerState<LimitForm> {
  final _formKey       = GlobalKey<FormState>();
  final _maxBouleCtrl  = TextEditingController();
  final _maxGlobalCtrl = TextEditingController();
  final _bouleCtrl     = TextEditingController();

  bool    _isGlobal  = true;
  String? _agentId;
  String? _tirageId;
  String? _typeJeu;
  String? _error;

  static const _typesJeu = ['borlette', 'mariage', 'lotto3', 'sel'];

  @override
  void dispose() {
    _maxBouleCtrl.dispose();
    _maxGlobalCtrl.dispose();
    _bouleCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final err = await ref
        .read(limitsNotifierProvider.notifier)
        .createLimit(
          agentId:    _isGlobal ? null : _agentId,
          tirageId:   _tirageId,
          typeJeu:    _typeJeu,
          boule:      _bouleCtrl.text.trim().isEmpty
              ? null
              : _bouleCtrl.text.trim(),
          maxParBoule: double.tryParse(_maxBouleCtrl.text) ?? 0,
          maxGlobal:   double.tryParse(_maxGlobalCtrl.text) ?? 0,
        );

    if (err != null) {
      setState(() => _error = err);
    } else {
      _reset();
      widget.onSuccess();
    }
  }

  void _reset() {
    _maxBouleCtrl.clear();
    _maxGlobalCtrl.clear();
    _bouleCtrl.clear();
    setState(() {
      _isGlobal = true;
      _agentId  = null;
      _tirageId = null;
      _typeJeu  = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(limitsNotifierProvider).isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Portée ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ScopeToggle(
                  label:    'Limite globale',
                  subtitle: 'S\'applique à tous',
                  icon:     Icons.public_rounded,
                  selected: _isGlobal,
                  onTap:    () => setState(() => _isGlobal = true),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ScopeToggle(
                  label:    'Par agent',
                  subtitle: 'Agent spécifique',
                  icon:     Icons.person_rounded,
                  selected: !_isGlobal,
                  onTap:    () => setState(() => _isGlobal = false),
                ),
              ),
            ],
          ),

          if (!_isGlobal) ...[
            const SizedBox(height: AppSpacing.md),
            _AgentDropdown(
              value:     _agentId,
              onChanged: (v) => setState(() => _agentId = v),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // ── Filtre jeu + boule ────────────────────────────
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue:      _typeJeu,
                  onChanged:  (v) => setState(() => _typeJeu = v),
                  decoration: const InputDecoration(
                    labelText:  'Type de jeu',
                    prefixIcon: Icon(Icons.category_rounded),
                    isDense:    true,
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
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _bouleCtrl,
                  decoration: const InputDecoration(
                    labelText:  'Boule (optionnel)',
                    prefixIcon: Icon(Icons.numbers_rounded),
                    hintText:   'ex: 13',
                    isDense:    true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Tirage ────────────────────────────────────────
          _TirageDropdown(
            value:     _tirageId,
            onChanged: (v) => setState(() => _tirageId = v),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Montants ──────────────────────────────────────
          const _SectionLabel(
            icon:  Icons.tune_rounded,
            label: 'Plafonds de vente',
          ),
          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _maxBouleCtrl,
                  decoration: const InputDecoration(
                    labelText:  'Max par boule (G)',
                    prefixIcon: Icon(Icons.arrow_upward_rounded),
                    isDense:    true,
                  ),
                  keyboardType: TextInputType.number,
                  validator:    Validators.positiveAmount,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _maxGlobalCtrl,
                  decoration: const InputDecoration(
                    labelText:  'Max global (G)',
                    prefixIcon: Icon(Icons.account_balance_rounded),
                    isDense:    true,
                  ),
                  keyboardType: TextInputType.number,
                  validator:    Validators.positiveAmount,
                ),
              ),
            ],
          ),

          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // ── Bouton ────────────────────────────────────────
          SizedBox(
            width:  double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _submit,
              icon: isLoading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_rounded, size: 18),
              label: Text(
                isLoading ? 'Création...' : 'Créer la limite',
              ),
            ),
          ),
        ],
      ),
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

class _ScopeToggle extends StatelessWidget {
  final String   label;
  final String   subtitle;
  final IconData icon;
  final bool     selected;
  final VoidCallback onTap;

  const _ScopeToggle({
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color:        selected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
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
              size:  18,
              color: selected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color:    Colors.grey.shade400,
                    ),
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

class _AgentDropdown extends ConsumerWidget {
  final String?            value;
  final ValueChanged<String?> onChanged;

  const _AgentDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(agentsStreamProvider).valueOrNull ?? [];
    return DropdownButtonFormField<String>(
      initialValue:      value,
      onChanged:  onChanged,
      decoration: const InputDecoration(
        labelText:  'Agent',
        prefixIcon: Icon(Icons.person_rounded),
        isDense:    true,
      ),
      hint: const Text('Sélectionner un agent'),
      items: agents
          .where((a) => a.isActif)
          .map(
            (a) => DropdownMenuItem(value: a.id, child: Text(a.nom)),
          )
          .toList(),
      validator: (v) =>
          v == null ? 'Veuillez sélectionner un agent.' : null,
    );
  }
}

class _TirageDropdown extends ConsumerWidget {
  final String?            value;
  final ValueChanged<String?> onChanged;

  const _TirageDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tirages = ref.watch(tiragesStreamProvider).valueOrNull ?? [];
    return DropdownButtonFormField<String?>(
      initialValue:      value,
      onChanged:  onChanged,
      decoration: const InputDecoration(
        labelText:  'Tirage (optionnel)',
        prefixIcon: Icon(Icons.casino_rounded),
        isDense:    true,
      ),
      hint: const Text('Tous les tirages'),
      items: [
        const DropdownMenuItem(
            value: null, child: Text('Tous les tirages')),
        ...tirages.map(
          (t) => DropdownMenuItem(value: t.id, child: Text(t.nom)),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize:   12,
            fontWeight: FontWeight.w600,
            color:      AppColors.primary,
          ),
        ),
      ],
    );
  }
}