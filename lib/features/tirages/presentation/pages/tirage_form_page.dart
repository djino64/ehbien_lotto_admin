// lib/features/tirages/presentation/pages/tirage_form_page.dart

import 'package:ehbien_lotto_admin/core/utils/validators.dart';
import 'package:ehbien_lotto_admin/features/tirages/domain/entities/tirage_entity.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/providers/tirages_provider.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TirageFormPage extends ConsumerStatefulWidget {
  final String? tirageId;
  const TirageFormPage({super.key, this.tirageId});

  bool get isEdit => tirageId != null;

  @override
  ConsumerState<TirageFormPage> createState() => _TirageFormPageState();
}

class _TirageFormPageState extends ConsumerState<TirageFormPage> {
  final _formKey  = GlobalKey<FormState>();
  final _nomCtrl  = TextEditingController();

  TirageType _type        = TirageType.borlette;
  DateTime   _heurePrevu  = DateTime.now().add(const Duration(hours: 1));
  bool       _isLoading   = false;
  String?    _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) _loadTirage();
  }

  Future<void> _loadTirage() async {
    final result = await ref
        .read(tiragesRepositoryProvider)
        .getTirageById(widget.tirageId!);
    result.fold(
      (f) => setState(() => _errorMessage = f.message),
      (t) => setState(() {
        _nomCtrl.text = t.nom;
        _type         = t.type;
        _heurePrevu   = t.heurePrevu;
      }),
    );
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context:     context,
      initialDate: _heurePrevu,
      firstDate:   DateTime.now(),
      lastDate:    DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context:     context,
      initialTime: TimeOfDay.fromDateTime(_heurePrevu),
    );
    if (time == null) return;

    setState(() {
      _heurePrevu = DateTime(
        date.year, date.month, date.day,
        time.hour, time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    String? error;

    if (widget.isEdit) {
      error = await ref
          .read(tiragesNotifierProvider.notifier)
          .updateTirage(
            id: widget.tirageId!,
            data: {
              'nom':        _nomCtrl.text.trim(),
              'type':       _type.name,
              'heurePrevu': _heurePrevu,
            },
          );
    } else {
      error = await ref
          .read(tiragesNotifierProvider.notifier)
          .createTirage(
            nom:        _nomCtrl.text.trim(),
            type:       _type.name,
            heurePrevu: _heurePrevu,
          );
    }

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(
            widget.isEdit
                ? 'Tirage modifié avec succès'
                : 'Tirage créé avec succès',
          ),
          backgroundColor: AppColors.success,
          behavior:        SnackBarBehavior.floating,
        ),
      );
      context.go(RouteNames.tiragesList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:        AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.casino_rounded,
                        color: AppColors.primary,
                        size:  22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEdit
                              ? 'Modifier le tirage'
                              : 'Nouveau tirage',
                          style: const TextStyle(
                            fontSize:   22,
                            fontWeight: FontWeight.w800,
                            color:      AppColors.primary,
                          ),
                        ),
                        Text(
                          widget.isEdit
                              ? 'Modifiez les informations du tirage'
                              : 'Configurez un nouveau tirage',
                          style: TextStyle(
                            fontSize: 13,
                            color:    Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Nom ──────────────────────
                          TextFormField(
                            controller: _nomCtrl,
                            decoration: const InputDecoration(
                              labelText:  'Nom du tirage',
                              prefixIcon: Icon(Icons.label_rounded),
                              hintText:   'ex: New York Midi, Tirage Soir...',
                            ),
                            validator: (v) =>
                                Validators.required(v, label: 'Le nom'),
                            textCapitalization: TextCapitalization.words,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // ── Type ─────────────────────
                          const Text(
                            'Type de jeu',
                            style: TextStyle(
                              fontSize:   12,
                              fontWeight: FontWeight.w600,
                              color:      AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _TypeSelector(
                            value:    _type,
                            onChanged: (t) => setState(() => _type = t),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // ── Heure prévue ─────────────
                          const Text(
                            'Heure prévue',
                            style: TextStyle(
                              fontSize:   12,
                              fontWeight: FontWeight.w600,
                              color:      AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          InkWell(
                            onTap:        _pickDateTime,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size:  18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      _formatDateTime(_heurePrevu),
                                      style: const TextStyle(
                                        fontSize:   14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit_calendar_rounded,
                                    size:  16,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Erreur ───────────────────
                          if (_errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm + 4),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.08),
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
                                    size:  16,
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

                          // ── Boutons ──────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () =>
                                    context.go(RouteNames.tiragesList),
                                child: const Text('Annuler'),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _submit,
                                icon: Icon(
                                  widget.isEdit
                                      ? Icons.save_rounded
                                      : Icons.casino_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  widget.isEdit
                                      ? 'Enregistrer'
                                      : 'Créer le tirage',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jul', 'aoû', 'sep', 'oct', 'nov', 'déc',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  •  $h:$m';
  }
}

// ── Sélecteur de type ─────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final TirageType                 value;
  final ValueChanged<TirageType>   onChanged;

  const _TypeSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TirageType.values.map((t) {
        final isSelected = t == value;
        final (emoji, label) = switch (t) {
          TirageType.borlette => ('🎱', 'Borlette'),
          TirageType.mariage  => ('💑', 'Mariage'),
          TirageType.lotto3   => ('🎰', 'Lotto 3'),
          TirageType.sel      => ('🧂', 'Sèl'),
        };

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: t != TirageType.sel ? AppSpacing.sm : 0,
            ),
            child: InkWell(
              onTap:        () => onChanged(t),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm + 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize:   11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}