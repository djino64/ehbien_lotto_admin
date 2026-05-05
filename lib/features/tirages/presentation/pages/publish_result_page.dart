// lib/features/tirages/presentation/pages/publish_result_page.dart

import 'package:ehbien_lotto_admin/features/tirages/domain/entities/tirage_entity.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/providers/tirages_provider.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/widgets/result_input_form.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/widgets/tirage_status_badge.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/error_state.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PublishResultPage extends ConsumerStatefulWidget {
  final String tirageId;
  const PublishResultPage({super.key, required this.tirageId});

  @override
  ConsumerState<PublishResultPage> createState() =>
      _PublishResultPageState();
}

class _PublishResultPageState extends ConsumerState<PublishResultPage> {
  final _formKey = GlobalKey<FormState>();
  List<String> _boules     = [];
  bool         _isLoading  = false;
  String?      _errorMessage;
  bool         _published  = false;

  @override
  Widget build(BuildContext context) {
    final tirageAsync = ref.watch(
      tirageByIdProvider(widget.tirageId),
    );

    return tirageAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(message: e.toString()),
      data: (tirage) {
        if (tirage == null) {
          return const ErrorState(message: 'Tirage introuvable.');
        }

        // Déjà publié
        if (tirage.isPublie || _published) {
          return _PublishedSuccess(
            tirage: tirage,
            boules: _boules,
          );
        }

        return LoadingOverlay(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────
                    _PublishHeader(tirage: tirage),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Avertissement ────────────────────
                    _WarningBanner(),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Formulaire résultat ──────────────
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              ResultInputForm(
                                type:          tirage.type,
                                initialBoules: _boules,
                                onChanged: (boules) =>
                                    setState(() => _boules = boules),
                              ),

                              if (_errorMessage != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:  AppColors.danger
                                        .withOpacity(0.08),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.danger
                                          .withOpacity(0.3),
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
                                            color:    AppColors.danger,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: AppSpacing.lg),

                              // ── Preview résultat ───────
                              if (_boules.isNotEmpty)
                                _ResultPreview(
                                  boules: _boules,
                                  tirage: tirage,
                                ),

                              const SizedBox(height: AppSpacing.lg),

                              // ── Boutons ────────────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => context.go(
                                      RouteNames.tiragesList,
                                    ),
                                    child: const Text('Annuler'),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  ElevatedButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : () => _publish(
                                            context, tirage),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(
                                      Icons.publish_rounded,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Publier le résultat',
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
      },
    );
  }

  Future<void> _publish(
    BuildContext context,
    TirageEntity tirage,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final expectedCount = switch (tirage.type) {
      TirageType.borlette => 3,
      TirageType.mariage  => 2,
      TirageType.lotto3   => 3,
      TirageType.sel      => 1,
    };

    if (_boules.length < expectedCount) {
      setState(() => _errorMessage =
          'Veuillez saisir les $expectedCount numéros gagnants.');
      return;
    }

    final confirm = await ConfirmDialog.show(
      context,
      title:   'Publier le résultat ?',
      message: 'Les boules gagnantes seront : ${_boules.join(' — ')}.\n\n'
          'Cette action déclenchera le calcul automatique des tickets gagnants '
          'et est irréversible.',
      confirmLabel: 'Publier',
    );

    if (confirm != true) return;

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    final error = await ref
        .read(tiragesNotifierProvider.notifier)
        .publishResult(
          tirageId: widget.tirageId,
          boules:   _boules,
        );

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      setState(() => _published = true);
    }
  }
}

// ── Header ────────────────────────────────────────────────────

class _PublishHeader extends StatelessWidget {
  final TirageEntity tirage;
  const _PublishHeader({required this.tirage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:        AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.publish_rounded,
            color: AppColors.success,
            size:  22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Publier le résultat',
                style: TextStyle(
                  fontSize:   22,
                  fontWeight: FontWeight.w800,
                  color:      AppColors.primary,
                ),
              ),
              Text(
                tirage.nom,
                style: TextStyle(
                  fontSize: 13,
                  color:    Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        TirageStatusBadge(status: tirage.status, large: true),
      ],
    );
  }
}

// ── Avertissement ─────────────────────────────────────────────

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size:  20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Action irréversible',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color:      AppColors.warning,
                    fontSize:   13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Une fois le résultat publié, tous les tickets gagnants '
                  'seront automatiquement marqués et les agents notifiés.',
                  style: TextStyle(
                    fontSize: 12,
                    color:    Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Preview du résultat ───────────────────────────────────────

class _ResultPreview extends StatelessWidget {
  final List<String>  boules;
  final TirageEntity  tirage;

  const _ResultPreview({
    required this.boules,
    required this.tirage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Aperçu du résultat — ${tirage.nom}',
            style: const TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: boules.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    Container(
                      width:  64,
                      height: 64,
                      decoration: BoxDecoration(
                        color:       AppColors.primary,
                        shape:       BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:      AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset:     const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          e.value.padLeft(2, '0'),
                          style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${e.key + 1}ème',
                      style: TextStyle(
                        fontSize: 10,
                        color:    Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Écran de confirmation après publication ───────────────────

class _PublishedSuccess extends StatelessWidget {
  final TirageEntity  tirage;
  final List<String>  boules;

  const _PublishedSuccess({
    required this.tirage,
    required this.boules,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width:  80,
                  height: 80,
                  decoration: BoxDecoration(
                    color:  AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size:  44,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                const Text(
                  'Résultat publié !',
                  style: TextStyle(
                    fontSize:   24,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Le résultat du tirage "${tirage.nom}" a été publié '
                  'avec succès. Les agents ont été notifiés.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color:    Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Boules publiées
                if (boules.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: boules.map((b) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                        child: Container(
                          width:  52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              b.padLeft(2, '0'),
                              style: const TextStyle(
                                color:      Colors.white,
                                fontSize:   18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: AppSpacing.xl),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.go(RouteNames.ticketsList),
                        icon:  const Icon(
                          Icons.receipt_long_rounded,
                          size: 16,
                        ),
                        label: const Text('Voir les tickets'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.go(RouteNames.tiragesList),
                        icon:  const Icon(
                          Icons.casino_rounded,
                          size: 16,
                        ),
                        label: const Text('Tirages'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}