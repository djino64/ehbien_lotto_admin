// lib/features/agents/presentation/widgets/agent_card.dart

import 'package:ehbien_lotto_admin/features/agents/domain/entities/agent_entity.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/widgets/agent_status_badge.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AgentCard extends ConsumerWidget {
  final AgentEntity agent;

  const AgentCard({super.key, required this.agent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête ──────────────────────────────────
            Row(
              children: [
                _AgentAvatar(nom: agent.nom),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.nom,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        agent.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                AgentStatusBadge(status: agent.status),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),

            // ── Succursale ────────────────────────────────
            if (agent.succursaleNom != null)
              _InfoRow(
                icon:  Icons.store_mall_directory_rounded,
                label: agent.succursaleNom!,
                color: AppColors.info,
              ),

            const SizedBox(height: AppSpacing.sm),

            // ── Limite ────────────────────────────────────
            _InfoRow(
              icon:  Icons.tune_rounded,
              label: 'Limite : ${agent.limiteJournaliere} G/jour',
              color: Colors.grey.shade500,
            ),

            if (agent.motDePasseTemp) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color:        AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.key_rounded,
                      size: 12,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Mot de passe temporaire',
                      style: TextStyle(
                        color:      AppColors.warning,
                        fontSize:   11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // ── Actions ───────────────────────────────────
            Row(
              children: [
                _ActionButton(
                  icon:    Icons.edit_rounded,
                  label:   'Modifier',
                  onTap:   () => context.go('/agents/${agent.id}/edit'),
                  color:   AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                _ActionButton(
                  icon:  agent.isBloque
                      ? Icons.lock_open_rounded
                      : Icons.block_rounded,
                  label: agent.isBloque ? 'Débloquer' : 'Bloquer',
                  color: agent.isBloque
                      ? AppColors.success
                      : AppColors.danger,
                  onTap: () => _toggleBlock(context, ref),
                ),
                const Spacer(),
                _ActionButton(
                  icon:  Icons.key_rounded,
                  label: 'Réinitialiser MDP',
                  color: Colors.grey.shade600,
                  onTap: () => _resetPassword(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBlock(BuildContext context, WidgetRef ref) async {
    final newStatus = agent.isBloque
        ? AgentStatus.actif
        : AgentStatus.bloque;

    final confirm = await ConfirmDialog.show(
      context,
      title:        agent.isBloque ? 'Débloquer l\'agent ?' : 'Bloquer l\'agent ?',
      message:      agent.isBloque
          ? 'L\'agent ${agent.nom} pourra à nouveau vendre des tickets.'
          : 'L\'agent ${agent.nom} ne pourra plus vendre de tickets.',
      confirmLabel: agent.isBloque ? 'Débloquer' : 'Bloquer',
      destructive:  !agent.isBloque,
    );

    if (confirm == true && context.mounted) {
      await ref
          .read(agentsNotifierProvider.notifier)
          .updateStatus(agent.id, newStatus);
    }
  }

  Future<void> _resetPassword(BuildContext context, WidgetRef ref) async {
    final confirm = await ConfirmDialog.show(
      context,
      title:        'Réinitialiser le mot de passe ?',
      message:      'Un email de réinitialisation sera envoyé à l\'agent ${agent.nom}.',
      confirmLabel: 'Envoyer',
    );

    if (confirm == true) {
      await ref
          .read(agentsNotifierProvider.notifier)
          .resetPassword(agent.userId, '');
    }
  }
}

// ── Sous-widgets ──────────────────────────────────────────────

class _AgentAvatar extends StatelessWidget {
  final String nom;
  const _AgentAvatar({required this.nom});

  String get _initials {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nom.substring(0, nom.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color get _color {
    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      const Color(0xFF6A1B9A),
      const Color(0xFF00838F),
    ];
    return colors[nom.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  44,
      height: 44,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color:        _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border:       Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color:      _color,
            fontWeight: FontWeight.w700,
            fontSize:   16,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize:   12,
                color:      color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}