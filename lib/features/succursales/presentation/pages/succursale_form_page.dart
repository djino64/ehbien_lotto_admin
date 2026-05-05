// lib/features/succursales/presentation/pages/succursale_form_page.dart

import 'package:ehbien_lotto_admin/core/utils/validators.dart';
import 'package:ehbien_lotto_admin/features/succursales/presentation/providers/succursales_provider.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SuccursaleFormPage extends ConsumerStatefulWidget {
  final String? succursaleId;

  const SuccursaleFormPage({super.key, this.succursaleId});

  bool get isEdit => succursaleId != null;

  @override
  ConsumerState<SuccursaleFormPage> createState() => _SuccursaleFormPageState();
}

class _SuccursaleFormPageState extends ConsumerState<SuccursaleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _telCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) _loadSuccursale();
  }

  Future<void> _loadSuccursale() async {
    setState(() => _isLoading = true);
    final result = await ref
        .read(succursalesRepositoryProvider)
        .getSuccursaleById(widget.succursaleId!);

    result.fold(
      (f) => setState(() {
        _errorMessage = f.message;
        _isLoading = false;
      }),
      (s) => setState(() {
        _nomCtrl.text = s.nom;
        _adresseCtrl.text = s.adresse;
        _telCtrl.text = s.telephone ?? '';
        _isLoading = false;
      }),
    );
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _adresseCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? error;

    if (widget.isEdit) {
      error = await ref.read(succursalesNotifierProvider.notifier).edit(
        id: widget.succursaleId!,
        data: {
          'nom': _nomCtrl.text.trim(),
          'adresse': _adresseCtrl.text.trim(),
          'telephone':
              _telCtrl.text.trim().isEmpty ? null : _telCtrl.text.trim(),
        },
      );
    } else {
      error = await ref.read(succursalesNotifierProvider.notifier).create(
            nom: _nomCtrl.text.trim(),
            adresse: _adresseCtrl.text.trim(),
            telephone:
                _telCtrl.text.trim().isEmpty ? null : _telCtrl.text.trim(),
          );
    }

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else if (mounted) {
      _showSuccess();
      context.go(RouteNames.succursalesList);
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.isEdit
                  ? 'Succursale modifiée avec succès'
                  : 'Succursale créée avec succès',
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────
                _FormHeader(isEdit: widget.isEdit),

                const SizedBox(height: AppSpacing.lg),

                // ── Formulaire ────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Informations ───────────────
                          const _SectionTitle(
                            icon: Icons.store_mall_directory_rounded,
                            label: 'Informations de la succursale',
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Nom
                          TextFormField(
                            controller: _nomCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nom de la succursale',
                              prefixIcon: Icon(
                                Icons.store_mall_directory_rounded,
                              ),
                              hintText: 'ex: Succursale Centre-Ville',
                            ),
                            validator: (v) => Validators.required(
                              v,
                              label: 'Le nom',
                            ),
                            enabled: !_isLoading,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Adresse
                          TextFormField(
                            controller: _adresseCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Adresse',
                              prefixIcon: Icon(
                                Icons.location_on_rounded,
                              ),
                              hintText: 'ex: Rue du Commerce, Port-au-Prince',
                              alignLabelWithHint: true,
                            ),
                            validator: (v) => Validators.required(
                              v,
                              label: 'L\'adresse',
                            ),
                            enabled: !_isLoading,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Téléphone
                          TextFormField(
                            controller: _telCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone (optionnel)',
                              prefixIcon: Icon(Icons.phone_rounded),
                              hintText: 'ex: 36000000',
                            ),
                            enabled: !_isLoading,
                          ),

                          // ── Erreur ─────────────────────
                          if (_errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            _ErrorBanner(message: _errorMessage!),
                          ],

                          const SizedBox(height: AppSpacing.lg),

                          // ── Boutons ────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => context.go(
                                  RouteNames.succursalesList,
                                ),
                                child: const Text('Annuler'),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _submit,
                                icon: Icon(
                                  widget.isEdit
                                      ? Icons.save_rounded
                                      : Icons.add_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  widget.isEdit
                                      ? 'Enregistrer'
                                      : 'Créer la succursale',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Carte info ────────────────────────────
                if (!widget.isEdit) ...[
                  const SizedBox(height: AppSpacing.md),
                  _InfoCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────

class _FormHeader extends StatelessWidget {
  final bool isEdit;
  const _FormHeader({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isEdit ? Icons.edit_rounded : Icons.add_business_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Modifier la succursale' : 'Nouvelle succursale',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              isEdit
                  ? 'Modifiez les informations de cette succursale'
                  : 'Créez un nouveau point de vente',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Section title ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionTitle({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Divider(color: Colors.grey.shade200),
        ),
      ],
    );
  }
}

// ── Bannière d'erreur ─────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.danger,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte d'information ───────────────────────────────────────

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.info,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'À savoir',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          _InfoItem(
            text:'Après la création, vous pouvez affecter des agents à cette succursale.',
          ),
          SizedBox(height: 4),
          _InfoItem(
            text:
                'Les statistiques de vente seront disponibles par succursale dans les rapports.',
          ),
          SizedBox(height: 4),
          _InfoItem(
            text:
                'Une succursale inactive empêche ses agents de vendre des tickets.',
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String text;
  const _InfoItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(top: 6, right: 8),
          decoration: const BoxDecoration(
            color: AppColors.info,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
