// lib/features/dashboard/presentation/widgets/succursale_overview_card.dart

import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/features/succursales/presentation/providers/succursales_provider.dart';
import 'package:ehbien_lotto_admin/features/ventes/presentation/providers/ventes_provider.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SuccursaleOverviewCard extends ConsumerWidget {
  const SuccursaleOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succursalesAsync = ref.watch(succursalesStreamProvider);
    final ventesResume     = ref.watch(ventesSummaryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.store_mall_directory_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Succursales',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      context.go(RouteNames.succursalesList),
                  child: const Text('Gérer'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            const Divider(),

            succursalesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => const Text('Erreur'),
              data: (succursales) {
                if (succursales.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Center(
                      child: Text(
                        'Aucune succursale',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: succursales.take(5).map((s) {
                    // Calcul ventes pour cette succursale
                    final ventesSuccursale = ventesResume
                        .where((v) => v.succursaleId == s.id)
                        .fold(0.0, (sum, v) => sum + v.montantTotal);

                    // Nombre d'agents
                    final nbAgents = ventesResume
                        .where((v) => v.succursaleId == s.id)
                        .length;

                    // Pourcentage
                    final total = ventesResume.fold(
                        0.0, (sum, v) => sum + v.montantTotal);
                    final pct = total > 0
                        ? (ventesSuccursale / total).clamp(0.0, 1.0)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.nom,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ventesSuccursale.toCurrency,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 6,
                                    backgroundColor:
                                        Colors.grey.shade100,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      _progressColor(pct),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$nbAgents agents',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _progressColor(double pct) {
    if (pct > 0.6) return AppColors.success;
    if (pct > 0.3) return AppColors.warning;
    return AppColors.info;
  }
}