// lib/features/blocages/presentation/widgets/blocage_scope_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/succursales/presentation/providers/succursales_provider.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/providers/tirages_provider.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';

enum BlocageScope { global, parAgent, parSuccursale, parTirage }

class BlocageScopeSelector extends ConsumerStatefulWidget {
  final BlocageScope        value;
  final ValueChanged<BlocageScope> onScopeChanged;
  final ValueChanged<String?> onAgentChanged;
  final ValueChanged<String?> onSuccursaleChanged;
  final ValueChanged<String?> onTirageChanged;
  final String? selectedAgentId;
  final String? selectedSuccursaleId;
  final String? selectedTirageId;

  const BlocageScopeSelector({
    super.key,
    required this.value,
    required this.onScopeChanged,
    required this.onAgentChanged,
    required this.onSuccursaleChanged,
    required this.onTirageChanged,
    this.selectedAgentId,
    this.selectedSuccursaleId,
    this.selectedTirageId,
  });

  @override
  ConsumerState<BlocageScopeSelector> createState() =>
      _BlocageScopeSelectorState();
}

class _BlocageScopeSelectorState
    extends ConsumerState<BlocageScopeSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Sélecteur de portée ───────────────────────────
        const Text(
          'Portée du blocage',
          style: TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w600,
            color:      AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: BlocageScope.values.map((scope) {
            final selected = widget.value == scope;
            final (label, icon) = switch (scope) {
              BlocageScope.global       => ('Global',      Icons.public_rounded),
              BlocageScope.parAgent     => ('Par agent',   Icons.person_rounded),
              BlocageScope.parSuccursale=> ('Par succursale', Icons.store_rounded),
              BlocageScope.parTirage    => ('Par tirage',  Icons.casino_rounded),
            };

            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size:  14,
                    color: selected ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(label),
                ],
              ),
              selected:          selected,
              onSelected: (_) => widget.onScopeChanged(scope),
              selectedColor:     AppColors.primary,
              labelStyle: TextStyle(
                color:      selected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize:   12,
              ),
              backgroundColor: AppColors.primary.withOpacity(0.05),
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.2),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Dropdown contextuel ───────────────────────────
        if (widget.value == BlocageScope.parAgent)
          _buildAgentDropdown(),

        if (widget.value == BlocageScope.parSuccursale)
          _buildSuccursaleDropdown(),

        if (widget.value == BlocageScope.parTirage)
          _buildTirageDropdown(),
      ],
    );
  }

  Widget _buildAgentDropdown() {
    final agents = ref.watch(agentsStreamProvider).valueOrNull ?? [];
    return DropdownButtonFormField<String>(
      initialValue:      widget.selectedAgentId,
      onChanged:  widget.onAgentChanged,
      decoration: const InputDecoration(
        labelText:  'Sélectionner l\'agent',
        prefixIcon: Icon(Icons.person_rounded),
      ),
      hint: const Text('Choisir un agent'),
      items: agents
          .where((a) => a.isActif)
          .map(
            (a) => DropdownMenuItem(
              value: a.id,
              child: Text(a.nom),
            ),
          )
          .toList(),
      validator: (v) =>
          v == null ? 'Veuillez sélectionner un agent.' : null,
    );
  }

  Widget _buildSuccursaleDropdown() {
    final succursales =
        ref.watch(succursalesStreamProvider).valueOrNull ?? [];
    return DropdownButtonFormField<String>(
      initialValue:      widget.selectedSuccursaleId,
      onChanged:  widget.onSuccursaleChanged,
      decoration: const InputDecoration(
        labelText:  'Sélectionner la succursale',
        prefixIcon: Icon(Icons.store_rounded),
      ),
      hint: const Text('Choisir une succursale'),
      items: succursales
          .where((s) => s.isActif)
          .map(
            (s) => DropdownMenuItem(
              value: s.id,
              child: Text(s.nom),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTirageDropdown() {
    final tirages = ref.watch(tiragesStreamProvider).valueOrNull ?? [];
    return DropdownButtonFormField<String>(
      initialValue:      widget.selectedTirageId,
      onChanged:  widget.onTirageChanged,
      decoration: const InputDecoration(
        labelText:  'Sélectionner le tirage',
        prefixIcon: Icon(Icons.casino_rounded),
      ),
      hint: const Text('Choisir un tirage'),
      items: tirages
          .where((t) => t.isOuvert)
          .map(
            (t) => DropdownMenuItem(
              value: t.id,
              child: Text(t.nom),
            ),
          )
          .toList(),
    );
  }
}