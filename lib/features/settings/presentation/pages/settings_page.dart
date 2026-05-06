// lib/features/settings/presentation/pages/settings_page.dart

import 'package:ehbien_lotto_admin/features/settings/domain/entities/app_setting_entity.dart';
import 'package:ehbien_lotto_admin/features/settings/presentation/providers/settings_provider.dart';
import 'package:ehbien_lotto_admin/features/settings/presentation/widgets/setting_tile.dart';
import 'package:ehbien_lotto_admin/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsStreamProvider);
    final isLoading = ref.watch(settingsNotifierProvider).isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      child: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(
            'Erreur : $e',
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
        data: (settings) {
          final map = {for (final s in settings) s.id: s};
          return SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Colonne gauche ─────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informations générales
                      const SettingsSectionHeader(
                        icon: Icons.info_rounded,
                        title: 'Informations générales',
                        subtitle: 'Nom et coordonnées de la loterie',
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.nomLotterie,
                        icon: Icons.casino_rounded,
                        label: 'Nom de la loterie',
                        description: 'Nom affiché dans l\'application',
                        defaultVal: 'Ehbien Lotto',
                        type: SettingType.text,
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.telephone,
                        icon: Icons.phone_rounded,
                        label: 'Téléphone de contact',
                        description: 'Numéro affiché aux vendeurs',
                        defaultVal: '36000000',
                        type: SettingType.text,
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.adresse,
                        icon: Icons.location_on_rounded,
                        label: 'Adresse du siège',
                        description: 'Adresse principale de la loterie',
                        defaultVal: 'Port-au-Prince, Haïti',
                        type: SettingType.text,
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.devise,
                        icon: Icons.attach_money_rounded,
                        label: 'Devise',
                        description: 'Devise utilisée (ex: HTG, USD)',
                        defaultVal: 'HTG',
                        type: SettingType.text,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Multiplicateurs de gains
                      const SettingsSectionHeader(
                        icon: Icons.calculate_rounded,
                        title: 'Multiplicateurs de gains',
                        subtitle: 'Facteur appliqué au montant misé',
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.multiplicateurBorlette,
                        icon: Icons.looks_one_rounded,
                        label: 'Borlette',
                        description: 'Multiplicateur pour la borlette',
                        defaultVal: '60',
                        type: SettingType.number,
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.multiplicateurMarriage,
                        icon: Icons.looks_two_rounded,
                        label: 'Mariage',
                        description: 'Multiplicateur pour le mariage',
                        defaultVal: '500',
                        type: SettingType.number,
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.multiplicateurLotto3,
                        icon: Icons.looks_3_rounded,
                        label: 'Lotto 3 chiffres',
                        description: 'Multiplicateur pour le lotto 3',
                        defaultVal: '800',
                        type: SettingType.number,
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.multiplicateurSel,
                        icon: Icons.looks_4_rounded,
                        label: 'Sèl',
                        description: 'Multiplicateur pour le sèl',
                        defaultVal: '10',
                        type: SettingType.number,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.lg),

                // ── Colonne droite ──────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Limites par défaut
                      const SettingsSectionHeader(
                        icon: Icons.tune_rounded,
                        title: 'Limites par défaut',
                        subtitle: 'Valeurs appliquées aux nouveaux agents',
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.limitJournaliereDefaut,
                        icon: Icons.speed_rounded,
                        label: 'Limite journalière',
                        description: 'Limite de vente par jour par agent',
                        defaultVal: '5000',
                        type: SettingType.currency,
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.limitParBouleDefaut,
                        icon: Icons.numbers_rounded,
                        label: 'Limite par boule',
                        description: 'Montant max par numéro joué',
                        defaultVal: '500',
                        type: SettingType.currency,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Fonctionnalités
                      const SettingsSectionHeader(
                        icon: Icons.toggle_on_rounded,
                        title: 'Fonctionnalités',
                        subtitle: 'Activation/désactivation des modules',
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.ventesActives,
                        icon: Icons.point_of_sale_rounded,
                        label: 'Ventes actives',
                        description: 'Autoriser la vente de tickets',
                        defaultVal: 'true',
                        type: SettingType.toggle,
                      ),
                      _buildTile(
                        map,
                        key: SettingKeys.maintenanceMode,
                        icon: Icons.build_rounded,
                        label: 'Mode maintenance',
                        description: 'Bloquer tous les accès vendeurs',
                        defaultVal: 'false',
                        type: SettingType.toggle,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Carte info
                      _InfoCard(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(
    Map<String, AppSettingEntity> map, {
    required String key,
    required IconData icon,
    required String label,
    required String description,
    required String defaultVal,
    required SettingType type,
  }) {
    final setting = map[key] ??
        AppSettingEntity(
          id: key,
          valeur: defaultVal,
          description: description,
          updatedAt: DateTime.now(),
          updatedBy: '',
        );

    return SettingTile(
      setting: setting,
      icon: icon,
      label: label,
      type: type,
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
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Important',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          _Item(
            'Les modifications sont appliquées immédiatement.',
          ),
          SizedBox(height: 4),
          _Item(
            'Les multiplicateurs affectent le calcul des gains sur les nouveaux tickets.',
          ),
          SizedBox(height: 4),
          _Item(
            'Le mode maintenance déconnecte tous les vendeurs actifs.',
          ),
          SizedBox(height: 4),
          _Item(
            'Les limites par défaut s\'appliquent uniquement aux nouveaux agents.',
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String text;
  const _Item(this.text);

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
            color: AppColors.warning,
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
